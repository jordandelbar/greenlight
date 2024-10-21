# Include variables from the .env file
include .env


# ========================================================================== #
# HELPERS
# ========================================================================== #

## help: print this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

# ========================================================================== #
# DEVELOPMENT
# ========================================================================== #

## run/dev-container: run the docker compose containers needed for development
.PHONY: run/dev-container
run/dev-container:
	docker compose up -d
	docker exec greenlight_postgres bash -c "\
        until pg_isready -U greenlight -d greenlight; do \
            echo 'Waiting for PostgreSQL...'; \
            sleep 2; \
        done; \
        psql -U greenlight -d greenlight -c 'CREATE EXTENSION IF NOT EXISTS citext;'"

## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	go run ./cmd/api/

## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/exec: Connect to the postgres docker
.PHONY:db/exec
db/exec:
	@echo 'Entering postgres docker'
	docker exec -it greenlight_postgres bash -c "\
	psql -U greenlight -d greenlight"

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up:
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up

# ========================================================================== #
# QUALITY CONTROL
# ========================================================================== #

## tidy: format all .go files and tidy module dependencies
.PHONY: tidy
tidy:
	@echo 'Formatting .go files...'
	go fmt ./...
	@echo 'Tidying module dependencies...'
	go mod tidy

## audit: run quality control checks
.PHONY: audit
audit:
	@echo 'Checking module dependencies'
	go mod tidy -diff
	go mod verify
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...