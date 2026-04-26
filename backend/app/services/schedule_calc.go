package services

import (
	"errors"
	"time"

	"doOrPay/backend/app/models"
)

func ValidateSchedule(s models.TaskSchedule) error {
	if s.Hour < 0 || s.Hour > 23 || s.Minute < 0 || s.Minute > 59 {
		return errors.New("schedule hour/minute out of range")
	}
	switch s.Type {
	case models.ScheduleOnce, models.ScheduleDaily:
		return nil
	case models.ScheduleWeekly:
		if len(s.DaysOfWeek) == 0 {
			return errors.New("weekly schedule requires daysOfWeek")
		}
		for _, d := range s.DaysOfWeek {
			if d < 0 || d > 6 {
				return errors.New("daysOfWeek must be 0..6")
			}
		}
		return nil
	default:
		return errors.New("unknown schedule type")
	}
}

func NextTrigger(now time.Time, tz string, sched models.TaskSchedule) (time.Time, error) {
	loc, err := time.LoadLocation(tz)
	if err != nil {
		return time.Time{}, errors.New("invalid timezone")
	}
	if err := ValidateSchedule(sched); err != nil {
		return time.Time{}, err
	}

	localNow := now.In(loc)
	base := time.Date(localNow.Year(), localNow.Month(), localNow.Day(), sched.Hour, sched.Minute, 0, 0, loc)

	switch sched.Type {
	case models.ScheduleOnce, models.ScheduleDaily:
		if !base.After(localNow) {
			base = base.Add(24 * time.Hour)
		}
		return base.UTC(), nil
	case models.ScheduleWeekly:
		allowed := map[int]bool{}
		for _, d := range sched.DaysOfWeek {
			allowed[d] = true
		}
		for i := 0; i <= 14; i++ {
			dt := base.AddDate(0, 0, i)
			if !allowed[int(dt.Weekday())] {
				continue
			}
			if i == 0 && !dt.After(localNow) {
				continue
			}
			return dt.UTC(), nil
		}
		return time.Time{}, errors.New("could not compute next weekly trigger")
	default:
		return time.Time{}, errors.New("unknown schedule type")
	}
}

