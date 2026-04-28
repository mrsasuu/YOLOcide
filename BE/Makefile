.PHONY: run build test tidy db-up db-down db-logs psql migrate fmt vet

# Default target: run the API server with .env loaded.
run:
	@set -a; [ -f .env ] && . ./.env; set +a; \
		go run ./cmd/api

build:
	go build -o bin/api ./cmd/api

test:
	go test ./...

tidy:
	go mod tidy

fmt:
	go fmt ./...

vet:
	go vet ./...

# Local Postgres lifecycle (docker-compose).
db-up:
	docker compose up -d postgres

db-down:
	docker compose down

db-logs:
	docker compose logs -f postgres

psql:
	docker compose exec postgres psql -U yolocide -d yolocide

# Manually re-run migrations (the API also runs them at startup).
migrate:
	@set -a; [ -f .env ] && . ./.env; set +a; \
		go run ./cmd/api -migrate-only

# Goose CLI shortcuts. These shell out to the goose CLI via `go run` so
# nothing needs to be installed globally. They operate on the same SQL
# files that get embedded into the binary.
GOOSE = go run github.com/pressly/goose/v3/cmd/goose
GOOSE_DIR = internal/db/migrations

goose-status:
	@set -a; [ -f .env ] && . ./.env; set +a; \
		$(GOOSE) -dir $(GOOSE_DIR) postgres "$$DATABASE_URL" status

goose-down:
	@set -a; [ -f .env ] && . ./.env; set +a; \
		$(GOOSE) -dir $(GOOSE_DIR) postgres "$$DATABASE_URL" down

goose-redo:
	@set -a; [ -f .env ] && . ./.env; set +a; \
		$(GOOSE) -dir $(GOOSE_DIR) postgres "$$DATABASE_URL" redo

# Create a new SQL migration. Usage: make goose-create name=add_wheels_table
goose-create:
	@if [ -z "$(name)" ]; then echo "usage: make goose-create name=<migration_name>"; exit 1; fi
	$(GOOSE) -dir $(GOOSE_DIR) -s create $(name) sql
