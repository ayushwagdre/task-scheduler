package web

import (
	"encoding/json"
	"net/http"

	"github.com/julienschmidt/httprouter"
)

const API_V1 = "v1"

type Request struct {
	W      http.ResponseWriter
	R      *http.Request
	Params httprouter.Params
}

type Response struct {
	Status      int
	Headers     map[string]string
	Body        any
	RawBytes    []byte
	RawMimeType string
}

type envelope struct {
	Success    bool        `json:"success"`
	Data       any         `json:"data,omitempty"`
	Error      *apiError   `json:"error,omitempty"`
	APIVersion string      `json:"api_version"`
}

type apiError struct {
	Code        string `json:"code"`
	Description string `json:"description"`
}

func NewResponse(data any, success bool, status int, apiVersion string) Response {
	return Response{Status: status, Body: envelope{Success: success, Data: data, APIVersion: apiVersion}}
}

func NewRawResponse(bytes []byte, mime string, status int) Response {
	return Response{Status: status, RawBytes: bytes, RawMimeType: mime}
}

func ErrBadRequest(desc string) Response          { return errWithStatus("bad_request", desc, http.StatusBadRequest) }
func ErrNotFound(desc string) Response            { return errWithStatus("not_found", desc, http.StatusNotFound) }
func ErrUnauthorized(desc string) Response        { return errWithStatus("unauthorized", desc, http.StatusUnauthorized) }
func ErrConflict(desc string) Response            { return errWithStatus("conflict", desc, http.StatusConflict) }
func ErrInternalServerError(desc string) Response { return errWithStatus("internal", desc, http.StatusInternalServerError) }
func ErrWithStatus(desc string, status int) Response {
	return errWithStatus("error", desc, status)
}

func errWithStatus(code, desc string, status int) Response {
	return Response{
		Status: status,
		Body: envelope{
			Success:    false,
			Error:      &apiError{Code: code, Description: desc},
			APIVersion: API_V1,
		},
	}
}

type Middleware func(Handler) Handler
type Handler func(*Request) Response

func Serve(middlewares []Middleware, handler Handler) httprouter.Handle {
	h := handler
	for i := len(middlewares) - 1; i >= 0; i-- {
		h = middlewares[i](h)
	}
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		req := &Request{W: w, R: r, Params: ps}
		resp := h(req)
		write(w, resp)
	}
}

func write(w http.ResponseWriter, resp Response) {
	for k, v := range resp.Headers {
		w.Header().Set(k, v)
	}
	if resp.RawBytes != nil {
		if resp.RawMimeType != "" {
			w.Header().Set("Content-Type", resp.RawMimeType)
		}
		w.WriteHeader(resp.Status)
		_, _ = w.Write(resp.RawBytes)
		return
	}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(resp.Status)
	_ = json.NewEncoder(w).Encode(resp.Body)
}

