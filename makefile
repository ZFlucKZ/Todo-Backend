.PHONY: setup-pre-commit
setup-pre-commit:
	@echo "Setting up pre-commit..."
	./scripts/setup-pre-commit.sh

.PHONY: test
test:
	@echo "Running tests..."
	go test -v ./...

.PHONY: run
run:
	@echo "Running the server..."
	go run main.go

.PHONY: test-it-docker
test-it-docker:
	docker-compose -f docker-compose.it.test.yaml down && \
	docker-compose -f docker-compose.it.test.yaml up --build --force-recreate --abort-on-container-exit --exit-code-from it_tests
