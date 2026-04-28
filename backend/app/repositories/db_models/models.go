package db_models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID           string    `gorm:"type:uuid;primaryKey"`
	Email        string    `gorm:"uniqueIndex;not null"`
	PasswordHash string    `gorm:"not null"`
	CreatedAt    time.Time `gorm:"not null;default:now()"`
	UpdatedAt    time.Time `gorm:"not null;default:now()"`
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == "" {
		u.ID = uuid.New().String()
	}
	return nil
}

type Task struct {
	ID              string    `gorm:"type:uuid;primaryKey"`
	UserID          string    `gorm:"type:uuid;index;not null"`
	Title           string    `gorm:"not null"`
	Description     string    `gorm:"not null;default:''"`
	ScheduleType    string    `gorm:"not null"`
	SchedulePayload []byte    `gorm:"type:jsonb;not null"`
	Timezone        string    `gorm:"not null"`
	NextTriggerAt   time.Time `gorm:"index;not null"`
	Active          bool      `gorm:"not null;default:true"`
	CreatedAt       time.Time `gorm:"not null;default:now()"`
	UpdatedAt       time.Time `gorm:"not null;default:now()"`
}

func (t *Task) BeforeCreate(tx *gorm.DB) error {
	if t.ID == "" {
		t.ID = uuid.New().String()
	}
	return nil
}

type TaskLog struct {
	ID        string    `gorm:"type:uuid;primaryKey"`
	TaskID    string    `gorm:"type:uuid;index;not null"`
	UserID    string    `gorm:"type:uuid;index;not null"`
	EventType string    `gorm:"not null"`
	EventAt   time.Time `gorm:"not null;default:now()"`
	Metadata  []byte    `gorm:"type:jsonb;not null;default:'{}'"`
}

func (t *TaskLog) BeforeCreate(tx *gorm.DB) error {
	if t.ID == "" {
		t.ID = uuid.New().String()
	}
	return nil
}

type Streak struct {
	UserID           string     `gorm:"type:uuid;primaryKey"`
	CurrentStreak    int        `gorm:"not null;default:0"`
	LongestStreak    int        `gorm:"not null;default:0"`
	LastCompletedDay *time.Time `gorm:"type:date"`
	UpdatedAt        time.Time  `gorm:"not null;default:now()"`
}

type AppEvent struct {
	ID        string    `gorm:"type:uuid;primaryKey"`
	InstallID string    `gorm:"index;not null"`
	UserID    *string   `gorm:"type:uuid;index"`
	EventType string    `gorm:"index;not null"`
	Metadata  []byte    `gorm:"type:jsonb;not null;default:'{}'"`
	CreatedAt time.Time `gorm:"not null;default:now()"`
}

func (a *AppEvent) BeforeCreate(tx *gorm.DB) error {
	if a.ID == "" {
		a.ID = uuid.New().String()
	}
	return nil
}

