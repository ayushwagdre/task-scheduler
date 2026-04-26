package models

import "time"

type ScheduleType string

const (
	ScheduleOnce   ScheduleType = "once"
	ScheduleDaily  ScheduleType = "daily"
	ScheduleWeekly ScheduleType = "weekly"
	ScheduleMonthly ScheduleType = "monthly"
)

type TaskSchedule struct {
	Type      ScheduleType `json:"type"`
	Hour      int          `json:"hour"`
	Minute    int          `json:"minute"`
	DaysOfWeek []int       `json:"daysOfWeek,omitempty"`
	DayOfMonth int         `json:"dayOfMonth,omitempty"`
}

type Task struct {
	ID            string       `json:"id"`
	UserID        string       `json:"userId"`
	Title         string       `json:"title"`
	Description   string       `json:"description"`
	Timezone      string       `json:"timezone"`
	Schedule      TaskSchedule `json:"schedule"`
	NextTriggerAt time.Time    `json:"nextTriggerAt"`
	Active        bool         `json:"active"`
	CreatedAt     time.Time    `json:"createdAt"`
	UpdatedAt     time.Time    `json:"updatedAt"`
}

type Streak struct {
	UserID           string    `json:"userId"`
	CurrentStreak    int       `json:"currentStreak"`
	LongestStreak    int       `json:"longestStreak"`
	LastCompletedDay time.Time `json:"lastCompletedDay,omitempty"`
	UpdatedAt        time.Time `json:"updatedAt"`
}

