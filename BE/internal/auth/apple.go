package auth

import (
	"context"
	"errors"
	"fmt"

	"github.com/golang-jwt/jwt/v5"
)

const (
	appleIssuer  = "https://appleid.apple.com"
	appleJWKSURL = "https://appleid.apple.com/auth/keys"
)

// AppleClaims is what we extract from a verified Apple identity token.
// Apple only sends `email` on the very first sign-in (and only if the user
// chose to share it). `EmailVerified` and `IsPrivateEmail` come back as
// strings ("true"/"false") in some Apple builds, so we tolerate both.
type AppleClaims struct {
	Sub            string `json:"sub"`
	Email          string `json:"email,omitempty"`
	EmailVerified  any    `json:"email_verified,omitempty"`
	IsPrivateEmail any    `json:"is_private_email,omitempty"`
	jwt.RegisteredClaims
}

type AppleVerifier struct {
	clientID string
	jwks     *jwksCache
}

func NewAppleVerifier(clientID string) *AppleVerifier {
	return &AppleVerifier{
		clientID: clientID,
		jwks:     newJWKSCache(appleJWKSURL),
	}
}

// Verify validates the signature and claims of an Apple identity token and
// returns the trusted claims. The token must:
//   - be RS256-signed with one of Apple's published JWKS keys
//   - have iss = https://appleid.apple.com
//   - have aud = our APPLE_CLIENT_ID (the iOS bundle identifier)
//   - not be expired
func (v *AppleVerifier) Verify(ctx context.Context, idToken string) (*AppleClaims, error) {
	if v.clientID == "" {
		return nil, errors.New("apple: APPLE_CLIENT_ID not configured")
	}

	claims := &AppleClaims{}
	parser := jwt.NewParser(
		jwt.WithValidMethods([]string{"RS256"}),
		jwt.WithIssuer(appleIssuer),
		jwt.WithAudience(v.clientID),
		jwt.WithExpirationRequired(),
	)

	_, err := parser.ParseWithClaims(idToken, claims, func(token *jwt.Token) (interface{}, error) {
		kid, _ := token.Header["kid"].(string)
		if kid == "" {
			return nil, errors.New("apple: missing kid header")
		}
		return v.jwks.keyByID(ctx, kid)
	})
	if err != nil {
		return nil, fmt.Errorf("apple: %w", err)
	}
	if claims.Sub == "" {
		return nil, errors.New("apple: token missing sub")
	}
	return claims, nil
}
