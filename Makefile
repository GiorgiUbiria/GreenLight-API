.PHONY: run-api

run-api:
	go run ./cmd/api

.PHONY:	curl

curl-health:
	curl -i http://localhost:4000/v1/healthcheck

.PHONY: migration
make-migration:
	migrate create -seq -ext=.sql -dir=./migrations $(name)
