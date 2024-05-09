.PHONY: run-api
run:
	@go run ./cmd/api

.PHONY:	curl

health-check:
	@curl -i http://localhost:4000/v1/healthcheck

.PHONY: migration_create
create-migration:
	@migrate create -seq -ext=.sql -dir=./migrations $(name)

.PHONY: update_database
update-database:
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) up

.PHONY: migration-version
migration-version:
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) version
