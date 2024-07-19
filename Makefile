.PHONY: connect-db
connect-db:
	docker exec -i -t greenlight_postgres bash

.PHONY: app/run-dev-container
app/run-dev-container:
	docker compose up -d

.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

.PHONY: db/migrations/up
db/migrations/up:
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up

.PHONY:db/exec
db/exec:
	@echo 'Entering postgres docker'
	docker exec -it greenlight_postgres /bin/bash