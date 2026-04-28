# YOLOcide Backend — Roadmap

This is a living document. The order is roughly the order things should ship. Each milestone is small enough to merge in a few PRs.

The end-state goal: a YOLOcide user can sign in on a fresh device and pull back **all** the wheels they've built and **all** their spin history, transparently. Until then the iOS app keeps working with `UserDefaults`-only persistence and ignores the backend.

---

## ✅ M0 — Auth foundation (shipped)

- Go service skeleton (chi, pgx, slog).
- Postgres connection pool + embedded SQL migration runner.
- `users` table.
- `POST /auth/apple` — verifies Apple identity token (JWKS, iss, aud, exp) and upserts user.
- `POST /auth/google` — verifies Google ID token via `idtoken.Validate` and upserts user.
- Session JWTs (HS256) issued by the backend; `Bearer` auth middleware.
- `GET /me`.
- `docker-compose` Postgres for local dev, Makefile, `.env.example`.

**What's deliberately not in M0:** account linking, refresh tokens, revocation, rate limiting, observability beyond access logs.

---

## M1 — iOS integration

Wire the iOS app to the new endpoints behind a feature flag. Do not migrate any local data yet.

- iOS: a thin `BackendClient` (URLSession) with a base URL config and a Keychain-backed token store.
- iOS: call `POST /auth/apple` after `ASAuthorizationAppleIDCredential` returns; store session JWT in Keychain.
- iOS: same for Google sign-in once the client lib is added.
- iOS: a "Sign out" path that drops the Keychain token (does not touch the backend).
- BE: structured request/response logging via `slog`.
- BE: minimum CORS policy (we don't need a permissive policy yet — the iOS app is the only client).

**Exit criteria:** signing in on the device round-trips through the backend and `GET /me` returns the same user across cold launches.

---

## M2 — Wheel + history sync data model

Add the tables we'll need to mirror the iOS app's `WheelOption` / `SpinSession` model. **Read-only on the iOS side** to start — the app will write through to UserDefaults locally and ignore these tables until M3 wires push.

Proposed schema (subject to change once we write it):

```
wheels
  id              uuid pk
  user_id         uuid fk -> users.id (cascade)
  name            text         -- nullable; iOS doesn't currently name wheels
  created_at      timestamptz
  updated_at      timestamptz
  deleted_at      timestamptz   -- soft-delete for sync correctness

wheel_options
  id              uuid pk
  wheel_id        uuid fk -> wheels.id (cascade)
  position        int           -- order within the wheel
  name            text not null
  color_hex       text not null
  created_at      timestamptz
  updated_at      timestamptz
  deleted_at      timestamptz

spin_sessions
  id              uuid pk
  user_id         uuid fk -> users.id (cascade)
  wheel_id        uuid fk -> wheels.id (set null)   -- snapshot lives in spin_session_options
  mode            text not null     -- 'single' | 'rank'
  started_at      timestamptz not null
  finished_at     timestamptz

spin_session_options
  -- frozen snapshot of the wheel at spin time, plus the result rank.
  -- mirrors iOS SessionOption (color stored as hex).
  spin_session_id uuid fk -> spin_sessions.id (cascade)
  position        int
  name            text not null
  color_hex       text not null
  rank            int           -- 1 = winner; null until determined
  primary key (spin_session_id, position)
```

Keep `wheels` mutable but version-bumped on every change so the sync protocol can use `updated_at` watermarks. `spin_sessions` are immutable once finished.

**Exit criteria:** migrations apply cleanly; we can hand-write an inserted spin via psql and read it back.

---

## M3 — Sync API (delta pull/push)

A single endpoint per resource, watermark-based, no real-time:

- `GET /sync/wheels?since=<timestamp>` → `{ wheels: [...], serverTime: ... }`
- `POST /sync/wheels` body `{ wheels: [...] }` → upsert by `id`, server resolves conflicts last-write-wins on `updated_at`.
- Same shape for `spin_sessions`.

iOS picks up the existing `HistoryStore` and `ContentView.options`, generates UUIDs for any local-only rows on first sync, then pushes. After the push, the iOS history page calls `GET /sync/spin_sessions?since=<lastWatermark>` on appear.

**Exit criteria:** a wheel created on Device A appears on Device B within one app launch on Device B.

---

## M4 — Account linking

If a user signs in with Apple, then later signs in with Google using the same email (and `email_verified=true`), prompt to link. Implementation:

- New endpoint `POST /auth/link` (authenticated) that verifies a second-provider token and writes its `sub` into the existing user row.
- Drop the `users_at_least_one_provider` check constraint into something more flexible (or keep it; linking only adds, never removes).
- Conflict path: if the second provider's `sub` is already on a different user row, surface a 409 with both user IDs and let the client offer a manual merge later (out of scope here).

---

## M5 — Hardening

- Rate limiting on `/auth/*` (per-IP token bucket; `chi/middleware.Throttle` or in-memory).
- Refresh tokens (rotate session JWTs without forcing re-auth via Apple/Google).
- Revocation table (`revoked_jti`) for forced sign-out.
- OpenTelemetry traces around DB calls and external JWKS fetches.
- Tests: `pgxmock` unit tests for the user repo; `httptest` integration tests against a real Postgres in CI.
- CI: GitHub Actions running `go vet`, `staticcheck`, `go test` against ephemeral Postgres.

---

## M6 — Deployment

- `Dockerfile` (multi-stage, distroless).
- Decide on host (Fly.io / Railway / a VPS); document it here.
- Managed Postgres choice; document it here.
- Production secrets management (no `.env` in prod).
- Health/readiness probes wired to whatever the host expects.

---

## Out of scope (for now)

- Web client. The backend is iOS-only until proven otherwise.
- Social features (sharing wheels with other users, public wheels).
- Anything requiring push notifications.
- Server-side wheel-spinning (the app is the source of truth for randomness).
