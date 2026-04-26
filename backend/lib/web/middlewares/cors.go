package middlewares

import (
	"net/http"

	"doOrPay/backend/lib/web"
)

func CORS(allowedOrigin string) web.Middleware {
	return func(next web.Handler) web.Handler {
		return func(req *web.Request) web.Response {
			w := req.W
			r := req.R
			if allowedOrigin == "" {
				allowedOrigin = "*"
			}
			w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
			w.Header().Set("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Authorization,Content-Type")
			if r.Method == http.MethodOptions {
				return web.NewResponse(map[string]any{"ok": true}, true, http.StatusOK, web.API_V1)
			}
			return next(req)
		}
	}
}

