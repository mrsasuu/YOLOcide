package auth

import (
	"context"
	"errors"
	"fmt"

	"google.golang.org/api/idtoken"
)

// GoogleClaims is the trusted subset we read from a verified Google ID
// token. The `idtoken` package validates signature, issuer, and audience
// against Google's published JWKS, so by the time we read these fields they
// are trustworthy.
type GoogleClaims struct {
	Sub           string
	Email         string
	EmailVerified bool
	Name          string
}

type GoogleVerifier struct {
	allowedAudiences []string
}

func NewGoogleVerifier(allowedAudiences []string) *GoogleVerifier {
	return &GoogleVerifier{allowedAudiences: allowedAudiences}
}

// Verify validates a Google ID token. It tries each configured audience
// (an iOS app may have multiple client IDs; the iOS SDK signs ID tokens
// with the iOS client ID, while a web flow would use the web client ID).
func (v *GoogleVerifier) Verify(ctx context.Context, idToken string) (*GoogleClaims, error) {
	if len(v.allowedAudiences) == 0 {
		return nil, errors.New("google: GOOGLE_CLIENT_IDS not configured")
	}

	var lastErr error
	for _, aud := range v.allowedAudiences {
		payload, err := idtoken.Validate(ctx, idToken, aud)
		if err != nil {
			lastErr = err
			continue
		}
		c := &GoogleClaims{Sub: payload.Subject}
		if email, ok := payload.Claims["email"].(string); ok {
			c.Email = email
		}
		if verified, ok := payload.Claims["email_verified"].(bool); ok {
			c.EmailVerified = verified
		}
		if name, ok := payload.Claims["name"].(string); ok {
			c.Name = name
		}
		if c.Sub == "" {
			return nil, errors.New("google: token missing sub")
		}
		return c, nil
	}
	return nil, fmt.Errorf("google: %w", lastErr)
}
