package services

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"doOrPay/backend/app/repositories"
	"doOrPay/backend/app/repositories/db_models"
)

type SchedulerService struct{}

func NewSchedulerService() *SchedulerService { return &SchedulerService{} }

// Tick finds due tasks, logs alarm_fired, and advances next_trigger_at.
// Notification delivery is mocked via logs for MVP.
func (s *SchedulerService) Tick(ctx context.Context, db *gorm.DB, now time.Time, limit int) {
	tasks, err := repositories.ListDueTasks(db.WithContext(ctx), now, limit)
	if err != nil {
		log.Printf("scheduler: list due: %v", err)
		return
	}
	for _, t := range tasks {
		_ = repositories.InsertTaskLog(db.WithContext(ctx), &db_models.TaskLog{
			ID:        uuid.NewString(),
			TaskID:    t.ID,
			UserID:    t.UserID,
			EventType: "alarm_fired",
			EventAt:   now.UTC(),
			Metadata:  mustJSON(map[string]any{"next_trigger_at": t.NextTriggerAt.Format(time.RFC3339)}),
		})

		next, err := NextTrigger(now, t.Timezone, repositories.DecodeSchedule(t.ScheduleType, t.SchedulePayload))
		if err != nil {
			log.Printf("scheduler: compute next for task %s: %v", t.ID, err)
			continue
		}
		if err := repositories.UpdateTaskNextTrigger(db.WithContext(ctx), t.ID, t.UserID, next, now.UTC()); err != nil {
			log.Printf("scheduler: update task %s: %v", t.ID, err)
			continue
		}
		log.Printf("scheduler: due task=%s user=%s title=%q (mock notify)", t.ID, t.UserID, t.Title)
	}
}

func mustJSON(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}

