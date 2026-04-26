package services

import "net/http"

type ServiceError struct {
	Status  int
	Code    string
	Message string
}

func (e *ServiceError) Error() string { return e.Message }

func ErrBadRequest(msg string) *ServiceError { return &ServiceError{Status: http.StatusBadRequest, Code: "bad_request", Message: msg} }
func ErrUnauthorized(msg string) *ServiceError { return &ServiceError{Status: http.StatusUnauthorized, Code: "unauthorized", Message: msg} }
func ErrNotFound(msg string) *ServiceError { return &ServiceError{Status: http.StatusNotFound, Code: "not_found", Message: msg} }
func ErrInternal(msg string) *ServiceError { return &ServiceError{Status: http.StatusInternalServerError, Code: "internal", Message: msg} }

