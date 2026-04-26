package config

import (
	"log"
	"os"
	"strconv"
	"sync"
	"time"
)

type Config struct {
	DatabaseURL string
	Port        string
	JWTSecret   string

	AccessTokenTTL time.Duration

	SchedulerEnabled    bool
	SchedulerTickPeriod time.Duration
}

var (
	once sync.Once
	cfg  Config
)

func Get() Config {
	once.Do(func() {
		cfg = load()
	})
	return cfg
}

func load() Config {
	c := Config{}
	c.DatabaseURL = mustGetenv("DATABASE_URL")
	c.JWTSecret = mustGetenv("JWT_SECRET")
	c.Port = getenv("PORT", "8080")

	ttlMin := getenvInt("ACCESS_TOKEN_TTL_MINUTES", 60)
	c.AccessTokenTTL = time.Duration(ttlMin) * time.Minute

	c.SchedulerEnabled = getenvBool("SCHEDULER_ENABLED", true)
	c.SchedulerTickPeriod = time.Duration(getenvInt("SCHEDULER_TICK_SECONDS", 60)) * time.Second
	return c
}

func mustGetenv(key string) string {
	v := os.Getenv(key)
	if v == "" {
		log.Fatalf("%s is required", key)
	}
	return v
}

func getenv(key, fallback string) string {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	return v
}

func getenvInt(key string, fallback int) int {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	i, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return i
}

func getenvBool(key string, fallback bool) bool {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	b, err := strconv.ParseBool(v)
	if err != nil {
		return fallback
	}
	return b
}

