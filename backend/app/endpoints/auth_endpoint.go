package endpoints

import (
	"encoding/json"
	"net/http"

	"doOrPay/backend/app/services"
	"doOrPay/backend/lib/db"
	"doOrPay/backend/lib/web"
)

type authEndpoint struct{ svc services.AuthServiceInterface }
type AuthEndpointOption func(*authEndpoint)

func WithAuthService(svc services.AuthServiceInterface) AuthEndpointOption {
	return func(e *authEndpoint) { e.svc = svc }
}

func SignupEndpoint(opts ...AuthEndpointOption) func(*web.Request) web.Response {
	e := &authEndpoint{svc: services.NewAuthService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.signup
}

func LoginEndpoint(opts ...AuthEndpointOption) func(*web.Request) web.Response {
	e := &authEndpoint{svc: services.NewAuthService()}
	for _, opt := range opts {
		opt(e)
	}
	return e.login
}

type authReq struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (e *authEndpoint) signup(req *web.Request) web.Response {
	var body authReq
	if err := json.NewDecoder(req.R.Body).Decode(&body); err != nil {
		return web.ErrBadRequest("invalid json")
	}
	out, serr := e.svc.Signup(req.R.Context(), db.Get(), body.Email, body.Password)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(out, true, http.StatusCreated, web.API_V1)
}

func (e *authEndpoint) login(req *web.Request) web.Response {
	var body authReq
	if err := json.NewDecoder(req.R.Body).Decode(&body); err != nil {
		return web.ErrBadRequest("invalid json")
	}
	out, serr := e.svc.Login(req.R.Context(), db.Get(), body.Email, body.Password)
	if serr != nil {
		return web.ErrWithStatus(serr.Message, serr.Status)
	}
	return web.NewResponse(out, true, http.StatusOK, web.API_V1)
}

