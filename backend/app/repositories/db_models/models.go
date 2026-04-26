package db_models

import "time"

type User struct {
	ID           string    `gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Email        string    `gorm:"uniqueIndex;not null"`
	PasswordHash string    `gorm:"not null"`
	CreatedAt    time.Time `gorm:"not null;default:now()"`
	UpdatedAt    time.Time `gorm:"not null;default:now()"`
}

type Task struct {
	ID             string    `gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID         string    `gorm:"type:uuid;index;not null"`
	Title          string    `gorm:"not null"`
	ScheduleType   string    `gorm:"not null"`
	SchedulePayload []byte   `gorm:"type:jsonb;not null"`
	Timezone       string    `gorm:"not null"`
	NextTriggerAt  time.Time `gorm:"index;not null"`
	Active         bool      `gorm:"not null;default:true"`
	CreatedAt      time.Time `gorm:"not null;default:now()"`
	UpdatedAt      time.Time `gorm:"not null;default:now()"`
}

type TaskLog struct {
	ID        string    `gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	TaskID    string    `gorm:"type:uuid;index;not null"`
	UserID    string    `gorm:"type:uuid;index;not null"`
	EventType string    `gorm:"not null"`
	EventAt   time.Time `gorm:"not null;default:now()"`
	Metadata  []byte    `gorm:"type:jsonb;not null;default:'{}'"`
}

type Streak struct {
	UserID          string     `gorm:"type:uuid;primaryKey"`
	CurrentStreak   int        `gorm:"not null;default:0"`
	LongestStreak   int        `gorm:"not null;default:0"`
	LastCompletedDay *time.Time `gorm:"type:date"`
	UpdatedAt       time.Time  `gorm:"not null;default:now()"`
}

