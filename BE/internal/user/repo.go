package user

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("user: not found")

type Repo struct {
	pool *pgxpool.Pool
}

func NewRepo(pool *pgxpool.Pool) *Repo {
	return &Repo{pool: pool}
}

const userCols = `id, apple_user_id, google_user_id, email, name, created_at, updated_at, last_login_at`

func scanUser(row pgx.Row) (*User, error) {
	var u User
	if err := row.Scan(
		&u.ID,
		&u.AppleUserID,
		&u.GoogleUserID,
		&u.Email,
		&u.Name,
		&u.CreatedAt,
		&u.UpdatedAt,
		&u.LastLoginAt,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &u, nil
}

func (r *Repo) Delete(ctx context.Context, id uuid.UUID) error {
	tag, err := r.pool.Exec(ctx, `DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("user: delete: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *Repo) ByID(ctx context.Context, id uuid.UUID) (*User, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE id = $1`, id)
	return scanUser(row)
}

func (r *Repo) ByAppleID(ctx context.Context, appleID string) (*User, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE apple_user_id = $1`, appleID)
	return scanUser(row)
}

func (r *Repo) ByGoogleID(ctx context.Context, googleID string) (*User, error) {
	row := r.pool.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE google_user_id = $1`, googleID)
	return scanUser(row)
}

// UpsertFromSignIn creates a user for a first-time sign-in or updates the
// existing user's last_login_at + any newly provided email/name. Matching
// is by provider ID only; we do not link providers by email here (an
// explicit "link account" flow can come later).
func (r *Repo) UpsertFromSignIn(ctx context.Context, in SignInInput) (*User, error) {
	switch in.Provider {
	case ProviderApple:
		return r.upsertApple(ctx, in)
	case ProviderGoogle:
		return r.upsertGoogle(ctx, in)
	default:
		return nil, fmt.Errorf("user: unknown provider %q", in.Provider)
	}
}

func (r *Repo) upsertApple(ctx context.Context, in SignInInput) (*User, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO users (apple_user_id, email, name, last_login_at)
		VALUES ($1, $2, $3, NOW())
		ON CONFLICT (apple_user_id) DO UPDATE SET
		    email         = COALESCE(EXCLUDED.email, users.email),
		    name          = COALESCE(EXCLUDED.name, users.name),
		    updated_at    = NOW(),
		    last_login_at = NOW()
		RETURNING `+userCols,
		in.ProviderID, in.Email, in.Name,
	)
	return scanUser(row)
}

func (r *Repo) upsertGoogle(ctx context.Context, in SignInInput) (*User, error) {
	row := r.pool.QueryRow(ctx, `
		INSERT INTO users (google_user_id, email, name, last_login_at)
		VALUES ($1, $2, $3, NOW())
		ON CONFLICT (google_user_id) DO UPDATE SET
		    email         = COALESCE(EXCLUDED.email, users.email),
		    name          = COALESCE(EXCLUDED.name, users.name),
		    updated_at    = NOW(),
		    last_login_at = NOW()
		RETURNING `+userCols,
		in.ProviderID, in.Email, in.Name,
	)
	return scanUser(row)
}
