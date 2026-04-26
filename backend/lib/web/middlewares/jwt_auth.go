package middlewares

import (
	"strings"

	"github.com/golang-jwt/jwt/v5"

	"doOrPay/backend/config"
	"doOrPay/backend/lib/web"
)

func RequireAuth() web.Middleware {
	return func(next web.Handler) web.Handler {
		return func(req *web.Request) web.Response {
			auth := req.R.Header.Get("Authorization")
			if auth == "" || !strings.HasPrefix(auth, "Bearer ") {
				return web.ErrUnauthorized("missing bearer token")
			}
			tokenStr := strings.TrimPrefix(auth, "Bearer ")

			cfg := config.Get()
			tok, err := jwt.Parse(tokenStr, func(token *jwt.Token) (any, error) {
				return []byte(cfg.JWTSecret), nil
			})
			if err != nil || !tok.Valid {
				return web.ErrUnauthorized("invalid token")
			}
			claims, ok := tok.Claims.(jwt.MapClaims)
			if !ok {
				return web.ErrUnauthorized("invalid token")
			}
			sub, _ := claims["sub"].(string)
			if sub == "" {
				return web.ErrUnauthorized("invalid token")
			}

			req.R = req.R.WithContext(web.WithUserID(req.R.Context(), sub))
			return next(req)
		}
	}
}

