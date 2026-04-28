package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

const sessionIssuer = "yolocide-be"

// SessionClaims is the payload we put in our own session JWTs (the token
// the iOS app holds after sign-in). Subject is the YOLOcide user UUID.
type SessionClaims struct {
	jwt.RegisteredClaims
}

type SessionIssuer struct {
	secret []byte
	ttl    time.Duration
}

func NewSessionIssuer(secret []byte, ttl time.Duration) *SessionIssuer {
	return &SessionIssuer{secret: secret, ttl: ttl}
}

func (s *SessionIssuer) Issue(userID uuid.UUID) (string, time.Time, error) {
	now := time.Now()
	expires := now.Add(s.ttl)
	claims := SessionClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID.String(),
			Issuer:    sessionIssuer,
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(expires),
		},
	}
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := tok.SignedString(s.secret)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("sign session: %w", err)
	}
	return signed, expires, nil
}

func (s *SessionIssuer) Verify(token string) (uuid.UUID, error) {
	claims := &SessionClaims{}
	parser := jwt.NewParser(
		jwt.WithValidMethods([]string{"HS256"}),
		jwt.WithIssuer(sessionIssuer),
		jwt.WithExpirationRequired(),
	)
	if _, err := parser.ParseWithClaims(token, claims, func(*jwt.Token) (interface{}, error) {
		return s.secret, nil
	}); err != nil {
		return uuid.Nil, err
	}
	if claims.Subject == "" {
		return uuid.Nil, errors.New("session: missing subject")
	}
	id, err := uuid.Parse(claims.Subject)
	if err != nil {
		return uuid.Nil, fmt.Errorf("session: invalid subject: %w", err)
	}
	return id, nil
}
