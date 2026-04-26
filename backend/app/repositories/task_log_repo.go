package repositories

import (
	"gorm.io/gorm"

	"doOrPay/backend/app/repositories/db_models"
)

func InsertTaskLog(db *gorm.DB, log *db_models.TaskLog) error {
	return db.Create(log).Error
}

