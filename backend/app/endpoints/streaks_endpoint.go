package endpoints

import (
	"net/http"

	"doOrPay/backend/app/services"
	"doOrPay/backend/lib/db"
	"doOrPay/backend/lib/web"
)

func GetStreaksEndpoint() func(*web.Request) web.Response {
	svc := services.NewStreakService()
	return func(req *web.Request) web.Response {
		userID, ok := web.UserIDFromContext(req.R.Context())
		if !ok {
			return web.ErrUnauthorized("unauthorized")
		}
		st, serr := svc.Get(req.R.Context(), db.Get(), userID)
		if serr != nil {
			return web.ErrWithStatus(serr.Message, serr.Status)
		}
		return web.NewResponse(st, true, http.StatusOK, web.API_V1)
	}
}

