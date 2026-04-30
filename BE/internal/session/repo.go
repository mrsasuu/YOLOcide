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

func (r *Repo) List(ctx context.Context, userID uuid.UUID) ([]SessionOutput, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, spun_at, is_ranked FROM spin_sessions WHERE user_id = $1 ORDER BY spun_at DESC`,
		userID,
	)
	if err != nil {
		return nil, fmt.Errorf("session list: query: %w", err)
	}
	defer rows.Close()

	var sessions []SessionOutput
	for rows.Next() {
		var s SessionOutput
		if err := rows.Scan(&s.ID, &s.SpunAt, &s.IsRanked); err != nil {
			return nil, fmt.Errorf("session list: scan: %w", err)
		}
		sessions = append(sessions, s)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("session list: rows: %w", err)
	}

	for i := range sessions {
		opts, err := r.listWheelOptions(ctx, sessions[i].ID)
		if err != nil {
			return nil, err
		}
		sessions[i].WheelOptions = opts

		results, err := r.listResults(ctx, sessions[i].ID)
		if err != nil {
			return nil, err
		}
		sessions[i].Results = results
	}

	return sessions, nil
}

func (r *Repo) listWheelOptions(ctx context.Context, sessionID uuid.UUID) ([]OptionOutput, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT name, color_hex FROM session_wheel_options WHERE session_id = $1`,
		sessionID,
	)
	if err != nil {
		return nil, fmt.Errorf("session wheel options: %w", err)
	}
	defer rows.Close()

	var opts []OptionOutput
	for rows.Next() {
		var o OptionOutput
		if err := rows.Scan(&o.Name, &o.ColorHex); err != nil {
			return nil, fmt.Errorf("session wheel options scan: %w", err)
		}
		opts = append(opts, o)
	}
	return opts, rows.Err()
}

func (r *Repo) listResults(ctx context.Context, sessionID uuid.UUID) ([]ResultOutput, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT name, color_hex, rank FROM session_results WHERE session_id = $1 ORDER BY rank ASC`,
		sessionID,
	)
	if err != nil {
		return nil, fmt.Errorf("session results: %w", err)
	}
	defer rows.Close()

	var results []ResultOutput
	for rows.Next() {
		var res ResultOutput
		if err := rows.Scan(&res.Name, &res.ColorHex, &res.Rank); err != nil {
			return nil, fmt.Errorf("session results scan: %w", err)
		}
		results = append(results, res)
	}
	return results, rows.Err()
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
