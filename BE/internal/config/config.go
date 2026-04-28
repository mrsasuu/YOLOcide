package config

import (
	"errors"
	"fmt"
	"os"
	"strings"
	"time"
)

type Config struct {
	Port             string
	DatabaseURL      string
	SessionSecret    []byte
	SessionTTL       time.Duration
	AppleClientID    string
	GoogleClientIDs  []string
}

func Load() (*Config, error) {
	c := &Config{
		Port:          getEnv("PORT", "8080"),
		DatabaseURL:   os.Getenv("DATABASE_URL"),
		AppleClientID: os.Getenv("APPLE_CLIENT_ID"),
	}

	if c.DatabaseURL == "" {
		return nil, errors.New("DATABASE_URL is required")
	}

	secret := os.Getenv("SESSION_JWT_SECRET")
	if len(secret) < 32 {
		return nil, errors.New("SESSION_JWT_SECRET must be at least 32 characters")
	}
	c.SessionSecret = []byte(secret)

	ttlStr := getEnv("SESSION_JWT_TTL", "720h")
	ttl, err := time.ParseDuration(ttlStr)
	if err != nil {
		return nil, fmt.Errorf("invalid SESSION_JWT_TTL %q: %w", ttlStr, err)
	}
	c.SessionTTL = ttl

	if ids := os.Getenv("GOOGLE_CLIENT_IDS"); ids != "" {
		for _, id := range strings.Split(ids, ",") {
			if trimmed := strings.TrimSpace(id); trimmed != "" {
				c.GoogleClientIDs = append(c.GoogleClientIDs, trimmed)
			}
		}
	}

	return c, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
