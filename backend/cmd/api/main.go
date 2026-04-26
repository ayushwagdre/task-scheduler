package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/joho/godotenv"
	"github.com/julienschmidt/httprouter"

	"doOrPay/backend/app/services"
	"doOrPay/backend/config"
	"doOrPay/backend/lib/db"
	v1 "doOrPay/backend/routes/v1"
)

func main() {
	_ = godotenv.Load() // local dev convenience

	cfg := config.Get()
	_ = db.Connect()

	router := httprouter.New()
	v1.Register(router)

	srv := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           router,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       60 * time.Second,
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		log.Printf("api listening on :%s", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %v", err)
		}
	}()

	// Scheduler loop (MVP): logs alarm_fired and advances next_trigger_at.
	// Runs in-process to keep infra simple.
	ctxScheduler, cancelScheduler := context.WithCancel(context.Background())
	if cfg.SchedulerEnabled {
		ticker := time.NewTicker(cfg.SchedulerTickPeriod)
		schedulerSvc := services.NewSchedulerService()
		go func() {
			defer ticker.Stop()
			for {
				select {
				case <-ticker.C:
					ctxTick, cancel := context.WithTimeout(ctxScheduler, 15*time.Second)
					schedulerSvc.Tick(ctxTick, db.Get(), time.Now().UTC(), 100)
					cancel()
				case <-ctxScheduler.Done():
					return
				}
			}
		}()
		log.Printf("scheduler enabled (tick=%s)", cfg.SchedulerTickPeriod)
	}

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)
	<-stop

	ctxShutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	cancelScheduler()
	_ = srv.Shutdown(ctxShutdown)
}

