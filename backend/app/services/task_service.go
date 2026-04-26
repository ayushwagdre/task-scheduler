package services

import (
	"context"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"doOrPay/backend/app/models"
	"doOrPay/backend/app/repositories"
	"doOrPay/backend/app/repositories/db_models"
)

type TaskServiceInterface interface {
	Create(ctx context.Context, db *gorm.DB, userID string, in CreateTaskInput) (*models.Task, *ServiceError)
	List(ctx context.Context, db *gorm.DB, userID string) ([]models.Task, *ServiceError)
	Get(ctx context.Context, db *gorm.DB, userID, taskID string) (*models.Task, *ServiceError)
	Update(ctx context.Context, db *gorm.DB, userID, taskID string, in UpdateTaskInput) (*models.Task, *ServiceError)
	Delete(ctx context.Context, db *gorm.DB, userID, taskID string) *ServiceError
	Complete(ctx context.Context, db *gorm.DB, userID, taskID string) (*models.Task, *ServiceError)
}

type taskService struct{}

func NewTaskService() TaskServiceInterface { return &taskService{} }

type CreateTaskInput struct {
	Title    string            `json:"title"`
	Timezone string            `json:"timezone"`
	Schedule models.TaskSchedule `json:"schedule"`
}

type UpdateTaskInput struct {
	Title    *string            `json:"title,omitempty"`
	Timezone *string            `json:"timezone,omitempty"`
	Schedule *models.TaskSchedule `json:"schedule,omitempty"`
	Active   *bool              `json:"active,omitempty"`
}

func (s *taskService) Create(ctx context.Context, db *gorm.DB, userID string, in CreateTaskInput) (*models.Task, *ServiceError) {
	if userID == "" {
		return nil, ErrUnauthorized("unauthorized")
	}
	if in.Title == "" || in.Timezone == "" {
		return nil, ErrBadRequest("title and timezone are required")
	}
	if err := ValidateSchedule(in.Schedule); err != nil {
		return nil, ErrBadRequest(err.Error())
	}

	now := time.Now().UTC()
	next, err := NextTrigger(now, in.Timezone, in.Schedule)
	if err != nil {
		return nil, ErrBadRequest(err.Error())
	}
	payload, err := repositories.EncodeSchedule(in.Schedule)
	if err != nil {
		return nil, ErrInternal("failed to encode schedule")
	}

	t := &db_models.Task{
		ID:              uuid.NewString(),
		UserID:          userID,
		Title:           in.Title,
		ScheduleType:    string(in.Schedule.Type),
		SchedulePayload: payload,
		Timezone:        in.Timezone,
		NextTriggerAt:   next.UTC(),
		Active:          true,
		CreatedAt:       now,
		UpdatedAt:       now,
	}
	if err := repositories.CreateTask(db.WithContext(ctx), t); err != nil {
		return nil, ErrInternal("failed to create task")
	}
	out := mapTaskModel(*t, repositories.DecodeSchedule(t.ScheduleType, t.SchedulePayload))
	return &out, nil
}

func (s *taskService) List(ctx context.Context, db *gorm.DB, userID string) ([]models.Task, *ServiceError) {
	rows, err := repositories.ListTasksByUser(db.WithContext(ctx), userID)
	if err != nil {
		return nil, ErrInternal("failed to list tasks")
	}
	out := make([]models.Task, 0, len(rows))
	for _, r := range rows {
		out = append(out, mapTaskModel(r, repositories.DecodeSchedule(r.ScheduleType, r.SchedulePayload)))
	}
	return out, nil
}

func (s *taskService) Get(ctx context.Context, db *gorm.DB, userID, taskID string) (*models.Task, *ServiceError) {
	t, err := repositories.GetTaskByID(db.WithContext(ctx), userID, taskID)
	if err != nil {
		return nil, ErrNotFound("task not found")
	}
	sched := repositories.DecodeSchedule(t.ScheduleType, t.SchedulePayload)
	out := mapTaskModel(*t, sched)
	return &out, nil
}

func (s *taskService) Update(ctx context.Context, db *gorm.DB, userID, taskID string, in UpdateTaskInput) (*models.Task, *ServiceError) {
	t, err := repositories.GetTaskByID(db.WithContext(ctx), userID, taskID)
	if err != nil {
		return nil, ErrNotFound("task not found")
	}

	if in.Title != nil {
		t.Title = *in.Title
	}
	if in.Timezone != nil {
		t.Timezone = *in.Timezone
	}
	if in.Active != nil {
		t.Active = *in.Active
	}

	schedule := repositories.DecodeSchedule(t.ScheduleType, t.SchedulePayload)
	if in.Schedule != nil {
		if err := ValidateSchedule(*in.Schedule); err != nil {
			return nil, ErrBadRequest(err.Error())
		}
		schedule = *in.Schedule
		payload, err := repositories.EncodeSchedule(schedule)
		if err != nil {
			return nil, ErrInternal("failed to encode schedule")
		}
		t.ScheduleType = string(schedule.Type)
		t.SchedulePayload = payload
	}

	// Recompute next trigger for updated schedule/timezone or reactivation.
	if in.Timezone != nil || in.Schedule != nil || (in.Active != nil && *in.Active) {
		next, err := NextTrigger(time.Now().UTC(), t.Timezone, schedule)
		if err != nil {
			return nil, ErrBadRequest(err.Error())
		}
		t.NextTriggerAt = next.UTC()
	}

	t.UpdatedAt = time.Now().UTC()
	if err := repositories.UpdateTask(db.WithContext(ctx), t); err != nil {
		return nil, ErrInternal("failed to update task")
	}
	out := mapTaskModel(*t, schedule)
	return &out, nil
}

func (s *taskService) Delete(ctx context.Context, db *gorm.DB, userID, taskID string) *ServiceError {
	if err := repositories.DeleteTask(db.WithContext(ctx), userID, taskID); err != nil {
		return ErrNotFound("task not found")
	}
	return nil
}

func (s *taskService) Complete(ctx context.Context, db *gorm.DB, userID, taskID string) (*models.Task, *ServiceError) {
	t, err := repositories.GetTaskByID(db.WithContext(ctx), userID, taskID)
	if err != nil {
		return nil, ErrNotFound("task not found")
	}
	sched := repositories.DecodeSchedule(t.ScheduleType, t.SchedulePayload)

	now := time.Now().UTC()
	if sched.Type == models.ScheduleOnce {
		t.Active = false
	} else {
		next, err := NextTrigger(now, t.Timezone, sched)
		if err != nil {
			return nil, ErrBadRequest(err.Error())
		}
		t.NextTriggerAt = next.UTC()
	}
	t.UpdatedAt = now

	if err := repositories.UpdateTask(db.WithContext(ctx), t); err != nil {
		return nil, ErrInternal("failed to update task")
	}
	out := mapTaskModel(*t, sched)
	return &out, nil
}

func mapTaskModel(t db_models.Task, sched models.TaskSchedule) models.Task {
	return models.Task{
		ID:            t.ID,
		UserID:        t.UserID,
		Title:         t.Title,
		Timezone:      t.Timezone,
		Schedule:      sched,
		NextTriggerAt: t.NextTriggerAt,
		Active:        t.Active,
		CreatedAt:     t.CreatedAt,
		UpdatedAt:     t.UpdatedAt,
	}
}

