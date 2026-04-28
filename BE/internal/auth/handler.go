package auth

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/yolocide/yolocide-be/internal/user"
)

type Handler struct {
	apple   *AppleVerifier
	google  *GoogleVerifier
	session *SessionIssuer
	users   *user.Repo
}

func NewHandler(apple *AppleVerifier, google *GoogleVerifier, session *SessionIssuer, users *user.Repo) *Handler {
	return &Handler{apple: apple, google: google, session: session, users: users}
}

type appleSignInRequest struct {
	IdentityToken string  `json:"identityToken"`
	Email         *string `json:"email,omitempty"`
	Name          *string `json:"name,omitempty"`
}

type googleSignInRequest struct {
	IdToken string `json:"idToken"`
}

type sessionResponse struct {
	Token     string    `json:"token"`
	ExpiresAt time.Time `json:"expiresAt"`
	User      *user.User `json:"user"`
}

func (h *Handler) HandleApple(w http.ResponseWriter, r *http.Request) {
	var req appleSignInRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body", "invalid JSON body")
		return
	}
	if strings.TrimSpace(req.IdentityToken) == "" {
		writeError(w, http.StatusBadRequest, "missing_token", "identityToken is required")
		return
	}

	claims, err := h.apple.Verify(r.Context(), req.IdentityToken)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "invalid_token", err.Error())
		return
	}

	in := user.SignInInput{
		Provider:   user.ProviderApple,
		ProviderID: claims.Sub,
		Name:       req.Name,
	}
	// Prefer the email that Apple signed inside the identity token over
	// any client-supplied value. Apple only includes email on first sign-in.
	switch {
	case claims.Email != "":
		email := claims.Email
		in.Email = &email
	case req.Email != nil && *req.Email != "":
		in.Email = req.Email
	}

	h.completeSignIn(w, r, in)
}

func (h *Handler) HandleGoogle(w http.ResponseWriter, r *http.Request) {
	var req googleSignInRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid_body", "invalid JSON body")
		return
	}
	if strings.TrimSpace(req.IdToken) == "" {
		writeError(w, http.StatusBadRequest, "missing_token", "idToken is required")
		return
	}

	claims, err := h.google.Verify(r.Context(), req.IdToken)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "invalid_token", err.Error())
		return
	}

	in := user.SignInInput{
		Provider:   user.ProviderGoogle,
		ProviderID: claims.Sub,
	}
	if claims.Email != "" {
		email := claims.Email
		in.Email = &email
	}
	if claims.Name != "" {
		name := claims.Name
		in.Name = &name
	}

	h.completeSignIn(w, r, in)
}

func (h *Handler) completeSignIn(w http.ResponseWriter, r *http.Request, in user.SignInInput) {
	u, err := h.users.UpsertFromSignIn(r.Context(), in)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "user_upsert_failed", err.Error())
		return
	}
	token, expires, err := h.session.Issue(u.ID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "session_issue_failed", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, sessionResponse{
		Token:     token,
		ExpiresAt: expires,
		User:      u,
	})
}

// HandleMe returns the authenticated user. Requires the auth middleware.
func (h *Handler) HandleMe(w http.ResponseWriter, r *http.Request) {
	uid, ok := UserIDFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized", "missing session")
		return
	}
	u, err := h.users.ByID(r.Context(), uid)
	if err != nil {
		if errors.Is(err, user.ErrNotFound) {
			writeError(w, http.StatusNotFound, "user_not_found", "user no longer exists")
			return
		}
		writeError(w, http.StatusInternalServerError, "user_lookup_failed", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, u)
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, map[string]string{"error": code, "message": message})
}
