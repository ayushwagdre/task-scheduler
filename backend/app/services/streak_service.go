package services

import (
	"context"
	"time"

	"gorm.io/gorm"

	"doOrPay/backend/app/models"
	"doOrPay/backend/app/repositories"
	"doOrPay/backend/app/repositories/db_models"
)

type StreakServiceInterface interface {
	Get(ctx context.Context, db *gorm.DB, userID string) (*models.Streak, *ServiceError)
	OnTaskCompleted(ctx context.Context, db *gorm.DB, userID string, completedAt time.Time, timezone string) (*models.Streak, *ServiceError)
}

type streakService struct{}

func NewStreakService() StreakServiceInterface { return &streakService{} }

func (s *streakService) Get(ctx context.Context, db *gorm.DB, userID string) (*models.Streak, *ServiceError) {
	st, err := repositories.GetOrCreateStreak(db.WithContext(ctx), userID)
	if err != nil {
		return nil, ErrInternal("failed to load streak")
	}
	return mapStreakModel(st), nil
}

func (s *streakService) OnTaskCompleted(ctx context.Context, db *gorm.DB, userID string, completedAt time.Time, timezone string) (*models.Streak, *ServiceError) {
	loc, err := time.LoadLocation(timezone)
	if err != nil {
		return nil, ErrBadRequest("invalid timezone")
	}
	st, err := repositories.GetOrCreateStreak(db.WithContext(ctx), userID)
	if err != nil {
		return nil, ErrInternal("failed to load streak")
	}

	dayLocal := time.Date(completedAt.In(loc).Year(), completedAt.In(loc).Month(), completedAt.In(loc).Day(), 0, 0, 0, 0, loc)
	dayUTC := time.Date(dayLocal.Year(), dayLocal.Month(), dayLocal.Day(), 0, 0, 0, 0, time.UTC)

	var lastUTC time.Time
	if st.LastCompletedDay != nil {
		lastUTC = st.LastCompletedDay.UTC()
	}

	if st.LastCompletedDay == nil {
		st.CurrentStreak = 1
	} else if sameYMD(dayUTC, lastUTC) {
		// already counted today
	} else if sameYMD(dayUTC, lastUTC.AddDate(0, 0, 1)) {
		st.CurrentStreak++
	} else {
		st.CurrentStreak = 1
	}
	if st.CurrentStreak > st.LongestStreak {
		st.LongestStreak = st.CurrentStreak
	}
	st.LastCompletedDay = &dayUTC
	st.UpdatedAt = time.Now().UTC()

	if err := repositories.UpdateStreak(db.WithContext(ctx), st); err != nil {
		return nil, ErrInternal("failed to update streak")
	}
	return mapStreakModel(st), nil
}

func mapStreakModel(st *db_models.Streak) *models.Streak {
	out := &models.Streak{
		UserID:         st.UserID,
		CurrentStreak:  st.CurrentStreak,
		LongestStreak:  st.LongestStreak,
		UpdatedAt:      st.UpdatedAt,
	}
	if st.LastCompletedDay != nil {
		out.LastCompletedDay = *st.LastCompletedDay
	}
	return out
}

func sameYMD(a, b time.Time) bool {
	return a.Year() == b.Year() && a.Month() == b.Month() && a.Day() == b.Day()
}

