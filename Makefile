confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

.PHONY: run-api
run:
	@go run ./cmd/api

.PHONY: health	
health:
	@curl -i http://localhost:4000/v1/healthcheck

.PHONY: migration
migration:
	@echo 'Creating migration files for ${name}...'
	@migrate create -seq -ext=.sql -dir=./migrations $(name)

.PHONY: up
up:
	@echo 'Running up migrations...'
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) up

.PHONY: migration-v
migration-v:
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) version
