package endpoints

import (
	"net/http"

	"doOrPay/backend/app/repositories"
	"doOrPay/backend/lib/db"
	"doOrPay/backend/lib/web"
)

func MeGetEndpoint() func(*web.Request) web.Response {
	return func(req *web.Request) web.Response {
		userID, ok := web.UserIDFromContext(req.R.Context())
		if !ok {
			return web.ErrUnauthorized("unauthorized")
		}
		u, err := repositories.GetUserByID(db.Get().WithContext(req.R.Context()), userID)
		if err != nil {
			return web.ErrNotFound("user not found")
		}
		return web.NewResponse(map[string]any{"id": u.ID, "email": u.Email}, true, http.StatusOK, web.API_V1)
	}
}

func MeDeleteEndpoint() func(*web.Request) web.Response {
	return func(req *web.Request) web.Response {
		userID, ok := web.UserIDFromContext(req.R.Context())
		if !ok {
			return web.ErrUnauthorized("unauthorized")
		}
		if err := repositories.DeleteUserByID(db.Get().WithContext(req.R.Context()), userID); err != nil {
			return web.ErrInternalServerError("failed to delete account")
		}
		return web.NewResponse(map[string]any{"deleted": true}, true, http.StatusOK, web.API_V1)
	}
}

