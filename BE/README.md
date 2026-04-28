# YOLOcide Backend

A Go HTTP API that backs the YOLOcide iOS app. Right now its only job is **authentication**: verify Sign in with Apple / Google ID tokens, create or update a user record in Postgres, and hand the iOS app back a session JWT it can use on future requests.

The scope intentionally stops there. See [ROADMAP.md](ROADMAP.md) for what comes next (sync of wheels, options, and spin history).

## Stack

| Layer        | Choice                                            |
|--------------|---------------------------------------------------|
| Language     | Go 1.23+                                          |
| Router       | [chi v5](https://github.com/go-chi/chi)           |
| DB driver    | [pgx v5 + pgxpool](https://github.com/jackc/pgx)  |
| DB           | Postgres 16                                       |
| Migrations   | [goose](https://github.com/pressly/goose) v3, embedded SQL, run at startup |
| Auth (in)    | Apple / Google ID token verification              |
| Auth (out)   | HS256 session JWTs issued by this service         |

No ORM. No DI framework. No code generation. SQL is hand-written.

## Project layout

```
BE/
├── cmd/api/                 entry point (main.go)
├── internal/
│   ├── auth/                Apple + Google verification, session JWT, handlers, middleware
│   ├── config/              env loading
│   ├── db/                  pgx pool + embedded migration runner
│   │   └── migrations/      *.up.sql files (committed)
│   ├── server/              chi router + route wiring
│   └── user/                user model + Postgres repository
├── docker-compose.yml       local Postgres
├── Makefile                 run / build / test / db helpers
├── .env.example             env template
├── README.md                this file
└── ROADMAP.md               next milestones
```

## Prerequisites

- Go 1.23+ — `brew install go`
- Docker (for local Postgres) — or your own Postgres instance

## First-time setup

```bash
cd BE

# 1. Pull deps and lock go.sum.
go mod tidy

# 2. Copy env template and fill in real values.
cp .env.example .env
# Then edit .env:
#   - SESSION_JWT_SECRET — generate with: openssl rand -base64 64
#   - APPLE_CLIENT_ID    — the iOS app bundle identifier
#   - GOOGLE_CLIENT_IDS  — the OAuth client ID(s) the iOS app uses

# 3. Start Postgres.
make db-up

# 4. Run the API. Migrations apply automatically on startup.
make run
```

The server listens on `http://localhost:8080`.

## Endpoints

| Method | Path           | Auth          | Purpose                                                  |
|--------|----------------|---------------|----------------------------------------------------------|
| GET    | `/healthz`     | —             | Liveness probe.                                          |
| POST   | `/auth/apple`  | —             | Exchange an Apple `identityToken` for a session JWT.     |
| POST   | `/auth/google` | —             | Exchange a Google `idToken` for a session JWT.           |
| GET    | `/me`          | Bearer JWT    | Return the authenticated user.                           |

### Sign in with Apple

```http
POST /auth/apple
Content-Type: application/json

{
  "identityToken": "eyJraWQiOiJYWZ...",
  "email": "user@example.com",
  "name": "Jane Doe"
}
```

`email` and `name` are only used on the **first** sign-in (Apple does not put the user's name in the identity token; the iOS SDK delivers it once via `ASAuthorizationAppleIDCredential.fullName`). Pass them through verbatim from the iOS client. Subsequent sign-ins can omit both fields.

The server verifies the `identityToken` against Apple's published JWKS at `https://appleid.apple.com/auth/keys`, requires `iss = https://appleid.apple.com`, and requires `aud = APPLE_CLIENT_ID`.

### Sign in with Google

```http
POST /auth/google
Content-Type: application/json

{
  "idToken": "eyJhbGciOi..."
}
```

Verified against Google's JWKS via `google.golang.org/api/idtoken`. The token's `aud` must match one of the entries in `GOOGLE_CLIENT_IDS`.

### Session response

Both sign-in endpoints return:

```json
{
  "token": "eyJhbGciOi...",
  "expiresAt": "2026-05-28T20:00:00Z",
  "user": {
    "id": "0e2c...-...",
    "appleUserId": "001234.abc...",
    "email": "user@example.com",
    "name": "Jane Doe",
    "createdAt": "2026-04-28T20:00:00Z",
    "updatedAt": "2026-04-28T20:00:00Z",
    "lastLoginAt": "2026-04-28T20:00:00Z"
  }
}
```

The iOS app stores the `token` (e.g. in the Keychain) and sends it on every authenticated request:

```
Authorization: Bearer <token>
```

## Database schema

See [internal/db/migrations/](internal/db/migrations/). The current schema is one `users` table:

| column           | type        | notes                                                   |
|------------------|-------------|---------------------------------------------------------|
| `id`             | UUID, PK    | `gen_random_uuid()` default                             |
| `apple_user_id`  | TEXT, UNIQUE| nullable; Apple's stable `sub`                          |
| `google_user_id` | TEXT, UNIQUE| nullable; Google's stable `sub`                         |
| `email`          | CITEXT      | nullable; case-insensitive                              |
| `name`           | TEXT        | nullable                                                |
| `created_at`     | TIMESTAMPTZ | `NOW()` default                                         |
| `updated_at`     | TIMESTAMPTZ | bumped on every sign-in                                 |
| `last_login_at`  | TIMESTAMPTZ | bumped on every sign-in                                 |

A check constraint enforces that at least one of `apple_user_id` / `google_user_id` is set.

Account linking (one user with both Apple and Google IDs) is not handled yet — it's a roadmap item.

## Migrations

Migrations live in `internal/db/migrations/` as plain SQL with goose annotations. They are embedded into the binary with `//go:embed` and applied at startup via the goose library API. Goose tracks applied migrations in its own `goose_db_version` table.

### Migration file format

```sql
-- +goose Up
CREATE TABLE example (...);

-- +goose Down
DROP TABLE example;
```

For statements that themselves contain semicolons (e.g. PL/pgSQL functions, triggers), wrap them in `-- +goose StatementBegin` / `-- +goose StatementEnd`.

### Adding a migration

```bash
make goose-create name=add_wheels_table
# generates internal/db/migrations/<timestamp>_add_wheels_table.sql
# edit the file, then restart the API (or run `make migrate`)
```

### Inspecting / rolling back

These shell out to the goose CLI via `go run` — no global install needed.

```bash
make goose-status    # show applied + pending migrations
make goose-down      # roll back the most recent migration
make goose-redo      # down + up the most recent migration
```

For a full local reset, drop the database: `make db-down && docker volume rm yolocide_be_yolocide_pgdata`.

## Testing

```bash
make test
```

(There are no tests yet — see ROADMAP.)

## Configuration reference

| Env var              | Required | Default | Description                                                  |
|----------------------|----------|---------|--------------------------------------------------------------|
| `PORT`               | no       | `8080`  | HTTP listen port.                                            |
| `DATABASE_URL`       | **yes**  | —       | Postgres connection string.                                  |
| `SESSION_JWT_SECRET` | **yes**  | —       | HS256 secret for session tokens. ≥ 32 chars.                 |
| `SESSION_JWT_TTL`    | no       | `720h`  | Session lifetime (Go duration).                              |
| `APPLE_CLIENT_ID`    | **yes**  | —       | iOS bundle identifier. Required `aud` for Apple ID tokens.   |
| `GOOGLE_CLIENT_IDS`  | **yes**  | —       | Comma-separated list of allowed Google OAuth audiences.      |

## Conventions

- **No third-party logger.** Use `log/slog` from the standard library.
- **No ORM.** SQL lives next to the repo type that uses it.
- **Errors propagate up with `%w`.** Callers decide how to render them.
- **Handlers are thin.** Verify input → call repo/service → return JSON. No business logic in handlers.
- **Time is `time.Time`, IDs are `uuid.UUID`.** No string-typed IDs in domain types.
