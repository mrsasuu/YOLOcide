package user

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID           uuid.UUID  `json:"id"`
	AppleUserID  *string    `json:"appleUserId,omitempty"`
	GoogleUserID *string    `json:"googleUserId,omitempty"`
	Email        *string    `json:"email,omitempty"`
	Name         *string    `json:"name,omitempty"`
	CreatedAt    time.Time  `json:"createdAt"`
	UpdatedAt    time.Time  `json:"updatedAt"`
	LastLoginAt  *time.Time `json:"lastLoginAt,omitempty"`
}

// Provider identifies which identity provider authenticated the request.
type Provider string

const (
	ProviderApple  Provider = "apple"
	ProviderGoogle Provider = "google"
)

// SignInInput is the normalized data we pull out of a verified Apple or
// Google ID token, plus optional name overrides Apple sends out-of-band on
// first sign-in (Apple does not put the name in the identity token; the
// iOS SDK delivers it once via ASAuthorizationAppleIDCredential).
type SignInInput struct {
	Provider   Provider
	ProviderID string
	Email      *string
	Name       *string
}
