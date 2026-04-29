-- Wheel spin sessions and their options/results.
--
-- spin_sessions        – one row per completed (or partial) spin session.
-- session_wheel_options – the options that were on the wheel when the session ran.
-- session_results      – the winner(s) in ranked order (rank=1 is the first pick).
--
-- For a normal (non-ranked) spin there is exactly one session_result row.
-- For a rank session there is one row per ranked option, ordered by rank ASC.

-- +goose Up

CREATE TABLE spin_sessions (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_ranked  BOOLEAN     NOT NULL DEFAULT FALSE,
    spun_at    TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX spin_sessions_user_id_idx ON spin_sessions (user_id);

CREATE TABLE session_wheel_options (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES spin_sessions(id) ON DELETE CASCADE,
    name       TEXT NOT NULL,
    color_hex  TEXT NOT NULL
);

CREATE INDEX session_wheel_options_session_idx ON session_wheel_options (session_id);

CREATE TABLE session_results (
    id         UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID    NOT NULL REFERENCES spin_sessions(id) ON DELETE CASCADE,
    name       TEXT    NOT NULL,
    color_hex  TEXT    NOT NULL,
    rank       INTEGER NOT NULL
);

CREATE INDEX session_results_session_idx ON session_results (session_id);

-- +goose Down

DROP TABLE IF EXISTS session_results;
DROP TABLE IF EXISTS session_wheel_options;
DROP TABLE IF EXISTS spin_sessions;
