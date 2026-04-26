package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"

	"doOrPay/backend/config"
)

func main() {
	_ = godotenv.Load()
	cfg := config.Get()

	if len(os.Args) < 2 {
		log.Fatalf("usage: migrate up|down")
	}
	dir := filepath.Join("migrations")

	db, err := sql.Open("pgx", cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("db: %v", err)
	}
	defer db.Close()

	ctx := context.Background()
	if err := ensureMigrationsTable(ctx, db); err != nil {
		log.Fatalf("migrations table: %v", err)
	}

	switch os.Args[1] {
	case "up":
		if err := applyUp(ctx, db, dir); err != nil {
			log.Fatalf("migrate up: %v", err)
		}
		log.Println("migrate up: done")
	case "down":
		if err := applyDownOne(ctx, db, dir); err != nil {
			log.Fatalf("migrate down: %v", err)
		}
		log.Println("migrate down: done")
	default:
		log.Fatalf("unknown command: %s", os.Args[1])
	}
}

func ensureMigrationsTable(ctx context.Context, db *sql.DB) error {
	_, err := db.ExecContext(ctx, `
CREATE TABLE IF NOT EXISTS schema_migrations (
  version TEXT PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);`)
	return err
}

func appliedVersions(ctx context.Context, db *sql.DB) (map[string]bool, error) {
	rows, err := db.QueryContext(ctx, `SELECT version FROM schema_migrations`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string]bool{}
	for rows.Next() {
		var v string
		if err := rows.Scan(&v); err != nil {
			return nil, err
		}
		out[v] = true
	}
	return out, rows.Err()
}

func applyUp(ctx context.Context, db *sql.DB, dir string) error {
	applied, err := appliedVersions(ctx, db)
	if err != nil {
		return err
	}
	files, err := os.ReadDir(dir)
	if err != nil {
		return err
	}
	var ups []string
	for _, f := range files {
		if f.IsDir() {
			continue
		}
		name := f.Name()
		if strings.HasSuffix(name, ".up.sql") {
			ups = append(ups, name)
		}
	}
	sort.Strings(ups)

	for _, name := range ups {
		version := strings.TrimSuffix(name, ".up.sql")
		if applied[version] {
			continue
		}
		path := filepath.Join(dir, name)
		sqlBytes, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		if err := runMigration(ctx, db, string(sqlBytes)); err != nil {
			return fmt.Errorf("%s: %w", name, err)
		}
		if _, err := db.ExecContext(ctx, `INSERT INTO schema_migrations (version) VALUES ($1)`, version); err != nil {
			return err
		}
	}
	return nil
}

func applyDownOne(ctx context.Context, db *sql.DB, dir string) error {
	row := db.QueryRowContext(ctx, `SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1`)
	var version string
	if err := row.Scan(&version); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil
		}
		return err
	}
	path := filepath.Join(dir, version+".down.sql")
	sqlBytes, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	if err := runMigration(ctx, db, string(sqlBytes)); err != nil {
		return err
	}
	_, err = db.ExecContext(ctx, `DELETE FROM schema_migrations WHERE version=$1`, version)
	return err
}

func runMigration(ctx context.Context, db *sql.DB, migrationSQL string) error {
	_, err := db.ExecContext(ctx, migrationSQL)
	return err
}

