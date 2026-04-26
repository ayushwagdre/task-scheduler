package repositories

import (
	"errors"

	"gorm.io/gorm"

	"doOrPay/backend/app/repositories/db_models"
)

func CreateUser(db *gorm.DB, email, passwordHash string) (*db_models.User, error) {
	u := &db_models.User{Email: email, PasswordHash: passwordHash}
	if err := db.Create(u).Error; err != nil {
		return nil, err
	}
	return u, nil
}

func GetUserByEmail(db *gorm.DB, email string) (*db_models.User, error) {
	var u db_models.User
	if err := db.Where("email = ?", email).First(&u).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &u, nil
}

func GetUserByID(db *gorm.DB, id string) (*db_models.User, error) {
	var u db_models.User
	if err := db.Where("id = ?", id).First(&u).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("user not found")
		}
		return nil, err
	}
	return &u, nil
}

func DeleteUserByID(db *gorm.DB, id string) error {
	return db.Where("id = ?", id).Delete(&db_models.User{}).Error
}

