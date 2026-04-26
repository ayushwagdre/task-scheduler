package repositories

import (
	"errors"
	"time"

	"gorm.io/gorm"

	"doOrPay/backend/app/repositories/db_models"
)

func GetOrCreateStreak(db *gorm.DB, userID string) (*db_models.Streak, error) {
	var st db_models.Streak
	if err := db.Where("user_id = ?", userID).First(&st).Error; err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, err
		}
		st = db_models.Streak{UserID: userID, CurrentStreak: 0, LongestStreak: 0, UpdatedAt: time.Now().UTC()}
		if err := db.Create(&st).Error; err != nil {
			return nil, err
		}
	}
	return &st, nil
}

func UpdateStreak(db *gorm.DB, st *db_models.Streak) error {
	return db.Save(st).Error
}

