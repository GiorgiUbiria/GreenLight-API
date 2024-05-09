help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

.PHONY: run/api
## run/api: run the cmd/api application
run/api:
	@go run ./cmd/api

.PHONY: api/health	
## api/health: check the health of the app 
api/health:
	@curl -i http://localhost:4000/v1/healthcheck

.PHONY: migrations/new
## migrations/new name=$1: create a new database migration
migrations/new:
	@echo 'Creating migration files for ${name}...'
	@migrate create -seq -ext=.sql -dir=./migrations $(name)

.PHONY: database/up
## database/up: apply all up database migrations
database/up:
	@echo 'Running up migrations...'
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) up

.PHONY: migration/version
## migrations/version: check migration version
migrations/version:
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) version
