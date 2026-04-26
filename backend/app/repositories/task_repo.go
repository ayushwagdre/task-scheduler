package repositories

import (
	"encoding/json"
	"errors"
	"time"

	"gorm.io/gorm"

	"doOrPay/backend/app/models"
	"doOrPay/backend/app/repositories/db_models"
)

func CreateTask(db *gorm.DB, t *db_models.Task) error {
	return db.Create(t).Error
}

func ListTasksByUser(db *gorm.DB, userID string) ([]db_models.Task, error) {
	var out []db_models.Task
	if err := db.Where("user_id = ?", userID).Order("created_at desc").Find(&out).Error; err != nil {
		return nil, err
	}
	return out, nil
}

func GetTaskByID(db *gorm.DB, userID, taskID string) (*db_models.Task, error) {
	var t db_models.Task
	if err := db.Where("id = ? AND user_id = ?", taskID, userID).First(&t).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("task not found")
		}
		return nil, err
	}
	return &t, nil
}

func UpdateTask(db *gorm.DB, t *db_models.Task) error {
	return db.Save(t).Error
}

func DeleteTask(db *gorm.DB, userID, taskID string) error {
	res := db.Where("id = ? AND user_id = ?", taskID, userID).Delete(&db_models.Task{})
	if res.Error != nil {
		return res.Error
	}
	if res.RowsAffected == 0 {
		return errors.New("task not found")
	}
	return nil
}

func ListDueTasks(db *gorm.DB, now time.Time, limit int) ([]db_models.Task, error) {
	var out []db_models.Task
	if err := db.Where("active = TRUE AND next_trigger_at <= ?", now.UTC()).
		Order("next_trigger_at asc").
		Limit(limit).
		Find(&out).Error; err != nil {
		return nil, err
	}
	return out, nil
}

func UpdateTaskNextTrigger(db *gorm.DB, taskID, userID string, next time.Time, updatedAt time.Time) error {
	return db.Model(&db_models.Task{}).
		Where("id = ? AND user_id = ?", taskID, userID).
		Updates(map[string]any{"next_trigger_at": next.UTC(), "updated_at": updatedAt.UTC()}).
		Error
}

func EncodeSchedule(s models.TaskSchedule) ([]byte, error) { return json.Marshal(s) }

func DecodeSchedule(scheduleType string, payload []byte) models.TaskSchedule {
	var s models.TaskSchedule
	_ = json.Unmarshal(payload, &s)
	// Trust payload; scheduleType kept for indexing/debugging.
	_ = scheduleType
	return s
}

