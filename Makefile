include .envrc

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	@go run ./cmd/api -db-dsn=${GREENLIGHT_DB_DSN}

## api/health: check the health of the app 
.PHONY: api/health	
api/health:
	@curl -i http://localhost:4000/v1/healthcheck

## migrations/new name=$1: create a new database migration
.PHONY: migrations/new
migrations/new:
	@echo 'Creating migration files for ${name}...'
	@migrate create -seq -ext=.sql -dir=./migrations $(name)

## database/up: apply all up database migrations
.PHONY: database/up
database/up:
	@echo 'Running up migrations...'
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) up

## migrations/version: check migration version
.PHONY: migration/version
migrations/version:
	@migrate -path=./migrations -database=$(GREENLIGHT_DB_DSN) version
