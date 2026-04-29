package session

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repo struct {
	pool *pgxpool.Pool
}

func NewRepo(pool *pgxpool.Pool) *Repo {
	return &Repo{pool: pool}
}

func (r *Repo) Create(ctx context.Context, in CreateInput) (uuid.UUID, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return uuid.Nil, fmt.Errorf("session: begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	var id uuid.UUID
	err = tx.QueryRow(ctx,
		`INSERT INTO spin_sessions (user_id, is_ranked, spun_at)
		 VALUES ($1, $2, $3)
		 RETURNING id`,
		in.UserID, in.IsRanked, in.SpunAt,
	).Scan(&id)
	if err != nil {
		return uuid.Nil, fmt.Errorf("session: insert: %w", err)
	}

	for _, o := range in.WheelOptions {
		if _, err := tx.Exec(ctx,
			`INSERT INTO session_wheel_options (session_id, name, color_hex)
			 VALUES ($1, $2, $3)`,
			id, o.Name, o.ColorHex,
		); err != nil {
			return uuid.Nil, fmt.Errorf("session: insert wheel option: %w", err)
		}
	}

	for _, res := range in.Results {
		if _, err := tx.Exec(ctx,
			`INSERT INTO session_results (session_id, name, color_hex, rank)
			 VALUES ($1, $2, $3, $4)`,
			id, res.Name, res.ColorHex, res.Rank,
		); err != nil {
			return uuid.Nil, fmt.Errorf("session: insert result: %w", err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return uuid.Nil, fmt.Errorf("session: commit: %w", err)
	}
	return id, nil
}
