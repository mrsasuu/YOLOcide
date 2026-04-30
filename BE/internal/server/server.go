package server

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/yolocide/yolocide-be/internal/auth"
	"github.com/yolocide/yolocide-be/internal/session"
)

type Deps struct {
	Auth     *auth.Handler
	Session  *auth.SessionIssuer
	Sessions *session.Handler
}

func New(deps Deps) http.Handler {
	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.CleanPath)
	r.Use(middleware.Timeout(30 * time.Second))

	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})

	r.Route("/auth", func(r chi.Router) {
		r.Post("/apple", deps.Auth.HandleApple)
		r.Post("/google", deps.Auth.HandleGoogle)
	})

	r.Group(func(r chi.Router) {
		r.Use(auth.Middleware(deps.Session))
		r.Get("/me", deps.Auth.HandleMe)
		r.Delete("/me", deps.Auth.HandleDeleteAccount)
		r.Get("/sessions", deps.Sessions.HandleList)
		r.Post("/sessions", deps.Sessions.HandleCreate)
	})

	return r
}
