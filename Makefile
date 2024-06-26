# Variables

GO_INSTALL_PATH = $(shell go env GOPATH)
STATICCHECK_CMD = $(GO_INSTALL_PATH)/bin/staticcheck

current_time = $(shell date --iso-8601=seconds)
git_description = $(shell git describe --always --dirty --tags --long)
linker_flags = '-s -X main.buildTime=${current_time} -X main.version=${git_description}'

# ENVIRONMENT VARIABLES

include .envrc

# Helpers 

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# Runners

## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	@go run ./cmd/api -db-dsn=${GREENLIGHT_DB_DSN}

## api/health: check the health of the app 
.PHONY: api/health	
api/health:
	@curl -i http://localhost:4000/v1/healthcheck

# Migrations

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

# Auditing and Vendoring

## audit: tidy and vendor dependencies and format, vet and test all code
.PHONY: audit
audit: vendor
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	$(STATICCHECK_CMD) ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

## build/api: build the cmd/api application
.PHONY: build/api
build/api:
	@echo 'Building cmd/api...'
	go build -ldflags=${linker_flags} -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/linux_amd64/api ./cmd/api
