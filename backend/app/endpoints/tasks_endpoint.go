package endpoints

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/google/uuid"

	"doOrPay/backend/app/repositories"
	"doOrPay/backend/app/repositories/db_models"
	"doOrPay/backend/app/services"
	"doOrPay/backend/lib/db"
	"doOrPay/backend/lib/web"
)

type tasksEndpoint struct{ svc services.TaskServiceInterface }
type TasksEndpointOption func(*tasksEndpoint)

func WithTaskService(svc services.TaskServiceInterface) TasksEndpointOption {
	return func(e *tasksEndpoint) { e.svc = svc }
}

func CreateTaskEndpoint(opts ...TasksEndpointOption) func(*web.Request) web.Response {
	e := &tasksEndpoint{svc: services.NewTaskService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.create
}

func ListTasksEndpoint(opts ...TasksEndpointOption) func(*web.Request) web.Response {
	e := &tasksEndpoint{svc: services.NewTaskService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.list
}

func UpdateTaskEndpoint(opts ...TasksEndpointOption) func(*web.Request) web.Response {
	e := &tasksEndpoint{svc: services.NewTaskService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.update
}

func GetTaskEndpoint(opts ...TasksEndpointOption) func(*web.Request) web.Response {
	e := &tasksEndpoint{svc: services.NewTaskService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.get
}

func DeleteTaskEndpoint(opts ...TasksEndpointOption) func(*web.Request) web.Response {
	e := &tasksEndpoint{svc: services.NewTaskService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.del
}

func CompleteTaskEndpoint(opts ...TasksEndpointOption) func(*web.Request) web.Response {
	e := &tasksEndpoint{svc: services.NewTaskService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.complete
}

func (e *tasksEndpoint) create(req *web.Request) web.Response {
	userID, ok := web.UserIDFromContext(req.R.Context())
	if !ok {
		return web.ErrUnauthorized("unauthorized")
	}
	var body services.CreateTaskInput
	if err := json.NewDecoder(req.R.Body).Decode(&body); err != nil {
		return web.ErrBadRequest("invalid json")
	}
	out, serr := e.svc.Create(req.R.Context(), db.Get(), userID, body)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(out, true, http.StatusCreated, web.API_V1)
}

func (e *tasksEndpoint) list(req *web.Request) web.Response {
	userID, ok := web.UserIDFromContext(req.R.Context())
	if !ok {
		return web.ErrUnauthorized("unauthorized")
	}
	out, serr := e.svc.List(req.R.Context(), db.Get(), userID)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(out, true, http.StatusOK, web.API_V1)
}

func (e *tasksEndpoint) update(req *web.Request) web.Response {
	userID, ok := web.UserIDFromContext(req.R.Context())
	if !ok {
		return web.ErrUnauthorized("unauthorized")
	}
	taskID := req.Params.ByName("id")
	var body services.UpdateTaskInput
	if err := json.NewDecoder(req.R.Body).Decode(&body); err != nil {
		return web.ErrBadRequest("invalid json")
	}
	out, serr := e.svc.Update(req.R.Context(), db.Get(), userID, taskID, body)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(out, true, http.StatusOK, web.API_V1)
}

func (e *tasksEndpoint) get(req *web.Request) web.Response {
	userID, ok := web.UserIDFromContext(req.R.Context())
	if !ok {
		return web.ErrUnauthorized("unauthorized")
	}
	taskID := req.Params.ByName("id")
	out, serr := e.svc.Get(req.R.Context(), db.Get(), userID, taskID)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(out, true, http.StatusOK, web.API_V1)
}

func (e *tasksEndpoint) del(req *web.Request) web.Response {
	userID, ok := web.UserIDFromContext(req.R.Context())
	if !ok {
		return web.ErrUnauthorized("unauthorized")
	}
	taskID := req.Params.ByName("id")
	if serr := e.svc.Delete(req.R.Context(), db.Get(), userID, taskID); serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(map[string]any{"deleted": true}, true, http.StatusOK, web.API_V1)
}

func (e *tasksEndpoint) complete(req *web.Request) web.Response {
	userID, ok := web.UserIDFromContext(req.R.Context())
	if !ok {
		return web.ErrUnauthorized("unauthorized")
	}
	taskID := req.Params.ByName("id")
	out, serr := e.svc.Complete(req.R.Context(), db.Get(), userID, taskID)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}

	// Log completion event (best-effort).
	_ = repositories.InsertTaskLog(db.Get().WithContext(req.R.Context()), &db_models.TaskLog{
		ID:        uuid.NewString(),
		TaskID:    taskID,
		UserID:    userID,
		EventType: "completed",
		EventAt:   time.Now().UTC(),
		Metadata:  []byte(`{}`),
	})

	streakSvc := services.NewStreakService()
	st, sErr := streakSvc.OnTaskCompleted(req.R.Context(), db.Get(), userID, time.Now().UTC(), out.Timezone)
	if sErr != nil {
		return web.ErrWithStatus(sErr.Message, sErr.Status)
	}

	return web.NewResponse(map[string]any{"task": out, "streak": st}, true, http.StatusOK, web.API_V1)
}

