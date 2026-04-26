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
	authMws := []web.Middleware{
		middlewares.CORS("*"),
		middlewares.RequireAuth(),
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

	// Account (protected) - required for Play account deletion policy
	router.GET("/me", web.Serve(authMws, endpoints.MeGetEndpoint()))
	router.DELETE("/me", web.Serve(authMws, endpoints.MeDeleteEndpoint()))

	// Tasks (protected)
	router.GET("/tasks", web.Serve(authMws, endpoints.ListTasksEndpoint()))
	router.POST("/tasks", web.Serve(authMws, endpoints.CreateTaskEndpoint()))
	router.GET("/tasks/:id", web.Serve(authMws, endpoints.GetTaskEndpoint()))
	router.PUT("/tasks/:id", web.Serve(authMws, endpoints.UpdateTaskEndpoint()))
	router.DELETE("/tasks/:id", web.Serve(authMws, endpoints.DeleteTaskEndpoint()))
	router.POST("/tasks/:id/complete", web.Serve(authMws, endpoints.CompleteTaskEndpoint()))

	// Streaks (protected)
	router.GET("/streaks", web.Serve(authMws, endpoints.GetStreaksEndpoint()))
}

