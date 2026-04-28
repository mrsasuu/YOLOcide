-- Users table.
--
-- Each row represents one human. A user authenticates with one or more
-- identity providers (Apple, Google). The provider's stable subject
-- identifier ("sub") is stored in apple_user_id / google_user_id and is
-- the source of truth for matching logins back to a user. Email and name
-- are denormalized from the latest provider response and may change.
--
-- Apple's identity token only includes the email on first sign-in (and
-- only if the user chose to share it). Apple may also issue a relay email
-- (@privaterelay.appleid.com) instead of the real one. So `email` and
-- `name` are nullable.

-- +goose Up
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apple_user_id   TEXT UNIQUE,
    google_user_id  TEXT UNIQUE,
    email           CITEXT,
    name            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at   TIMESTAMPTZ,
    CONSTRAINT users_at_least_one_provider
        CHECK (apple_user_id IS NOT NULL OR google_user_id IS NOT NULL)
);

CREATE INDEX users_email_idx ON users (email) WHERE email IS NOT NULL;

-- +goose Down
DROP TABLE IF EXISTS users;
-- Extensions are intentionally left in place; other future migrations
-- may rely on them and dropping them here would cascade unexpectedly.
