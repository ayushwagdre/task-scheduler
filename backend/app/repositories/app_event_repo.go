package repositories

import "gorm.io/gorm"

import "doOrPay/backend/app/repositories/db_models"

func InsertAppEvent(db *gorm.DB, ev *db_models.AppEvent) error {
	return db.Create(ev).Error
}

