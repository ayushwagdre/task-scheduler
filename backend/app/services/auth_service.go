package services

import (
	"context"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"doOrPay/backend/config"
	"doOrPay/backend/app/repositories"
)

type AuthServiceInterface interface {
	Signup(ctx context.Context, db *gorm.DB, email, password string) (map[string]any, *ServiceError)
	Login(ctx context.Context, db *gorm.DB, email, password string) (map[string]any, *ServiceError)
}

type authService struct{}

func NewAuthService() AuthServiceInterface { return &authService{} }

func (s *authService) Signup(ctx context.Context, db *gorm.DB, email, password string) (map[string]any, *ServiceError) {
	if email == "" || password == "" {
		return nil, ErrBadRequest("email and password are required")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, ErrInternal("failed to create account")
	}
	u, err := repositories.CreateUser(db.WithContext(ctx), email, string(hash))
	if err != nil {
		return nil, ErrBadRequest("could not create user")
	}
	return map[string]any{"id": u.ID, "email": u.Email}, nil
}

func (s *authService) Login(ctx context.Context, db *gorm.DB, email, password string) (map[string]any, *ServiceError) {
	if email == "" || password == "" {
		return nil, ErrBadRequest("email and password are required")
	}
	u, err := repositories.GetUserByEmail(db.WithContext(ctx), email)
	if err != nil {
		return nil, ErrUnauthorized("invalid credentials")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password)); err != nil {
		return nil, ErrUnauthorized("invalid credentials")
	}

	cfg := config.Get()
	now := time.Now()
	claims := jwt.MapClaims{
		"sub": u.ID,
		"iat": now.Unix(),
		"exp": now.Add(cfg.AccessTokenTTL).Unix(),
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := tok.SignedString([]byte(cfg.JWTSecret))
	if err != nil {
		return nil, ErrInternal("failed to sign token")
	}
	return map[string]any{"accessToken": signed}, nil
}

