package endpoints

import (
	"encoding/json"
	"net/http"

	"doOrPay/backend/app/repositories"
	"doOrPay/backend/app/repositories/db_models"
	"doOrPay/backend/lib/db"
	"doOrPay/backend/lib/web"
)

type createEventInput struct {
	InstallID string                 `json:"installId"`
	EventType string                 `json:"eventType"`
	Metadata  map[string]any         `json:"metadata"`
}

// EventsEndpoint accepts privacy-safe app lifecycle/product events.
// It does not require auth; if a request is authenticated, user_id is attached.
func EventsEndpoint() func(*web.Request) web.Response {
	return func(req *web.Request) web.Response {
		var body createEventInput
		if err := json.NewDecoder(req.R.Body).Decode(&body); err != nil {
			return web.ErrBadRequest("invalid json")
		}
		if body.InstallID == "" || body.EventType == "" {
			return web.ErrBadRequest("installId and eventType are required")
		}
		if body.Metadata == nil {
			body.Metadata = map[string]any{}
		}
		metaBytes, _ := json.Marshal(body.Metadata)

		var userID *string
		if uid, ok := web.UserIDFromContext(req.R.Context()); ok && uid != "" {
			userID = &uid
		}

		ev := &db_models.AppEvent{
			InstallID: body.InstallID,
			UserID:    userID,
			EventType: body.EventType,
			Metadata:  metaBytes,
		}

		if err := repositories.InsertAppEvent(db.Get().WithContext(req.R.Context()), ev); err != nil {
			return web.ErrInternalServerError("failed to create event")
		}
		return web.NewResponse(map[string]any{"ok": true}, true, http.StatusCreated, web.API_V1)
	}
}

