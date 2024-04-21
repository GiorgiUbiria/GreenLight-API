.PHONY: run-api

run-api:
	go run ./cmd/api

.PHONY:	curl

curl-health:
	curl -i http://localhost:4000/v1/healthcheck

.PHONY: migration_create
make-migration:
	migrate create -seq -ext=.sql -dir=./migrations $(name)

.PHONY: update_database
update-database:
	migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) up

.PHONY: migration-version
migration-version:
	migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) version
