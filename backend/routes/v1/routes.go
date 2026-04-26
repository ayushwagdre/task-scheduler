package v1

import (
	"net/http"

	"github.com/julienschmidt/httprouter"

	"doOrPay/backend/app/endpoints"
	"doOrPay/backend/lib/web"
	"doOrPay/backend/lib/web/middlewares"
)

func Register(router *httprouter.Router) {
	mws := []web.Middleware{
		middlewares.CORS("*"),
	}

	// Important for browsers: CORS preflight requests hit OPTIONS and should not 404.
	router.OPTIONS("/*path", web.Serve(mws, func(req *web.Request) web.Response {
		return web.NewResponse(map[string]any{"ok": true}, true, http.StatusOK, web.API_V1)
	}))

	router.GET("/healthz", web.Serve(mws, func(req *web.Request) web.Response {
		return web.NewResponse(map[string]any{"ok": true}, true, http.StatusOK, web.API_V1)
	}))

	router.POST("/auth/signup", web.Serve(mws, endpoints.SignupEndpoint()))
	router.POST("/auth/login", web.Serve(mws, endpoints.LoginEndpoint()))
}

