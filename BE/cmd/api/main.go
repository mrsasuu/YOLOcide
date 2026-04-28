package main

import (
	"context"
	"errors"
	"flag"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/yolocide/yolocide-be/internal/auth"
	"github.com/yolocide/yolocide-be/internal/config"
	"github.com/yolocide/yolocide-be/internal/db"
	"github.com/yolocide/yolocide-be/internal/server"
	"github.com/yolocide/yolocide-be/internal/user"
)

func main() {
	migrateOnly := flag.Bool("migrate-only", false, "run pending migrations and exit")
	flag.Parse()

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	slog.SetDefault(logger)

	cfg, err := config.Load()
	if err != nil {
		logger.Error("config load failed", "err", err)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := db.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		logger.Error("db pool failed", "err", err)
		os.Exit(1)
	}
	defer pool.Close()

	if err := db.Migrate(ctx, cfg.DatabaseURL); err != nil {
		logger.Error("migrate failed", "err", err)
		os.Exit(1)
	}
	logger.Info("migrations applied")

	if *migrateOnly {
		return
	}

	users := user.NewRepo(pool)
	apple := auth.NewAppleVerifier(cfg.AppleClientID)
	google := auth.NewGoogleVerifier(cfg.GoogleClientIDs)
	session := auth.NewSessionIssuer(cfg.SessionSecret, cfg.SessionTTL)
	authH := auth.NewHandler(apple, google, session, users)

	handler := server.New(server.Deps{Auth: authH, Session: session})

	srv := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           handler,
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		logger.Info("listening", "port", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("server error", "err", err)
			stop()
		}
	}()

	<-ctx.Done()
	logger.Info("shutting down")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		logger.Error("shutdown error", "err", err)
	}
}
