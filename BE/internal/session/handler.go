package session

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/yolocide/yolocide-be/internal/auth"
)

type Handler struct {
	repo *Repo
}

func NewHandler(repo *Repo) *Handler {
	return &Handler{repo: repo}
}

type createRequest struct {
	SpunAt       time.Time     `json:"spunAt"`
	IsRanked     bool          `json:"isRanked"`
	WheelOptions []OptionInput `json:"wheelOptions"`
	Results      []ResultInput `json:"results"`
}

func (h *Handler) HandleCreate(w http.ResponseWriter, r *http.Request) {
	uid, ok := auth.UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized", "missing session")
		return
	}

	var req createRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body", "invalid JSON body")
		return
	}
	if len(req.WheelOptions) == 0 {
		writeError(w, http.StatusBadRequest, "missing_options", "wheelOptions is required")
		return
	}
	if len(req.Results) == 0 {
		writeError(w, http.StatusBadRequest, "missing_results", "results is required")
		return
	}

	id, err := h.repo.Create(r.Context(), CreateInput{
		UserID:       uid,
		SpunAt:       req.SpunAt,
		IsRanked:     req.IsRanked,
		WheelOptions: req.WheelOptions,
		Results:      req.Results,
	})
	if err != nil {
		writeError(w, http.StatusInternalServerError, "session_create_failed", err.Error())
		return
	}

	writeJSON(w, http.StatusCreated, map[string]string{"id": id.String()})
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, map[string]string{"error": code, "message": message})
}
