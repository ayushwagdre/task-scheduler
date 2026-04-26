package db

import (
	"log"
	"sync"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"doOrPay/backend/config"
)

var (
	once sync.Once
	conn *gorm.DB
)

func Connect() *gorm.DB {
	once.Do(func() {
		cfg := config.Get()
		db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Silent),
		})
		if err != nil {
			log.Fatalf("db connect: %v", err)
		}
		conn = db
	})
	return conn
}

func Get() *gorm.DB { return Connect() }

