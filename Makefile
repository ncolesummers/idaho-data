# Idaho Data API Makefile
# Variables
BINARY_NAME=idaho-data-api
GO_FILES=$(shell find . -name '*.go' -type f)
COVERAGE_FILE=coverage.out
DOCKER_IMAGE=idaho-data-api
DOCKER_TAG=latest

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=gofmt
GOVET=$(GOCMD) vet

# Build parameters
BUILD_DIR=bin
MAIN_FILE=cmd/server/main.go

# Colors for output
COLOR_GREEN=\033[0;32m
COLOR_YELLOW=\033[0;33m
COLOR_BLUE=\033[0;36m
COLOR_NC=\033[0m # No Color

.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help screen
	@echo '$(COLOR_BLUE)Idaho Data API - Available commands:$(COLOR_NC)'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(COLOR_GREEN)%-30s$(COLOR_NC) %s\n", $$1, $$2}'

# Build commands
.PHONY: build
build: ## Build the binary
	@echo '$(COLOR_YELLOW)Building binary...$(COLOR_NC)'
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME) -v $(MAIN_FILE)
	@echo '$(COLOR_GREEN)Build complete: $(BUILD_DIR)/$(BINARY_NAME)$(COLOR_NC)'

.PHONY: build-all
build-all: ## Build for multiple platforms
	@echo '$(COLOR_YELLOW)Building for multiple platforms...$(COLOR_NC)'
	@mkdir -p $(BUILD_DIR)
	# Linux
	GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 -v $(MAIN_FILE)
	GOOS=linux GOARCH=arm64 $(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 -v $(MAIN_FILE)
	# macOS
	GOOS=darwin GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 -v $(MAIN_FILE)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 -v $(MAIN_FILE)
	# Windows
	GOOS=windows GOARCH=amd64 $(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe -v $(MAIN_FILE)
	@echo '$(COLOR_GREEN)Multi-platform build complete$(COLOR_NC)'

.PHONY: clean
clean: ## Remove build artifacts
	@echo '$(COLOR_YELLOW)Cleaning build artifacts...$(COLOR_NC)'
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
	rm -f $(COVERAGE_FILE)
	rm -f coverage.html
	@echo '$(COLOR_GREEN)Clean complete$(COLOR_NC)'

# Test commands
.PHONY: test
test: ## Run all tests
	@echo '$(COLOR_YELLOW)Running tests...$(COLOR_NC)'
	$(GOTEST) ./...

.PHONY: test-verbose
test-verbose: ## Run tests with verbose output
	@echo '$(COLOR_YELLOW)Running tests (verbose)...$(COLOR_NC)'
	$(GOTEST) -v ./...

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	@echo '$(COLOR_YELLOW)Running tests with coverage...$(COLOR_NC)'
	$(GOTEST) -race -coverprofile=$(COVERAGE_FILE) -covermode=atomic ./...
	@echo '$(COLOR_GREEN)Coverage report generated: $(COVERAGE_FILE)$(COLOR_NC)'

.PHONY: coverage-html
coverage-html: test-coverage ## Generate HTML coverage report
	@echo '$(COLOR_YELLOW)Generating HTML coverage report...$(COLOR_NC)'
	$(GOCMD) tool cover -html=$(COVERAGE_FILE) -o coverage.html
	@echo '$(COLOR_GREEN)HTML coverage report generated: coverage.html$(COLOR_NC)'

# Development commands
.PHONY: run
run: build ## Build and run the application
	@echo '$(COLOR_YELLOW)Running application...$(COLOR_NC)'
	./$(BUILD_DIR)/$(BINARY_NAME)

.PHONY: watch
watch: ## Run with file watcher (requires air)
	@echo '$(COLOR_YELLOW)Running with file watcher...$(COLOR_NC)'
	@which air > /dev/null || (echo '$(COLOR_YELLOW)Installing air...$(COLOR_NC)' && go install github.com/cosmtrek/air@latest)
	air

.PHONY: fmt
fmt: ## Format all Go files
	@echo '$(COLOR_YELLOW)Formatting Go files...$(COLOR_NC)'
	$(GOFMT) -w $(GO_FILES)
	@echo '$(COLOR_GREEN)Formatting complete$(COLOR_NC)'

.PHONY: vet
vet: ## Run go vet
	@echo '$(COLOR_YELLOW)Running go vet...$(COLOR_NC)'
	$(GOVET) ./...
	@echo '$(COLOR_GREEN)Vet complete$(COLOR_NC)'

.PHONY: lint
lint: ## Run golangci-lint
	@echo '$(COLOR_YELLOW)Running golangci-lint...$(COLOR_NC)'
	@which golangci-lint > /dev/null || (echo '$(COLOR_YELLOW)Installing golangci-lint...$(COLOR_NC)' && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest)
	golangci-lint run ./...
	@echo '$(COLOR_GREEN)Linting complete$(COLOR_NC)'

# Dependency commands
.PHONY: deps
deps: ## Download dependencies
	@echo '$(COLOR_YELLOW)Downloading dependencies...$(COLOR_NC)'
	$(GOGET) -d -v ./...
	@echo '$(COLOR_GREEN)Dependencies downloaded$(COLOR_NC)'

.PHONY: deps-update
deps-update: ## Update dependencies
	@echo '$(COLOR_YELLOW)Updating dependencies...$(COLOR_NC)'
	$(GOGET) -u -v ./...
	$(GOMOD) tidy
	@echo '$(COLOR_GREEN)Dependencies updated$(COLOR_NC)'

.PHONY: deps-tidy
deps-tidy: ## Run go mod tidy
	@echo '$(COLOR_YELLOW)Tidying dependencies...$(COLOR_NC)'
	$(GOMOD) tidy
	@echo '$(COLOR_GREEN)Dependencies tidied$(COLOR_NC)'

# Docker commands
.PHONY: docker-build
docker-build: ## Build Docker image
	@echo '$(COLOR_YELLOW)Building Docker image...$(COLOR_NC)'
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	@echo '$(COLOR_GREEN)Docker image built: $(DOCKER_IMAGE):$(DOCKER_TAG)$(COLOR_NC)'

.PHONY: docker-run
docker-run: ## Run Docker container
	@echo '$(COLOR_YELLOW)Running Docker container...$(COLOR_NC)'
	docker run -p 8080:8080 $(DOCKER_IMAGE):$(DOCKER_TAG)

# Development setup commands
.PHONY: setup
setup: deps ## Initial project setup
	@echo '$(COLOR_YELLOW)Setting up project...$(COLOR_NC)'
	$(GOMOD) download
	@echo '$(COLOR_GREEN)Project setup complete$(COLOR_NC)'

.PHONY: check
check: fmt vet lint test ## Run all checks (fmt, vet, lint, test)
	@echo '$(COLOR_GREEN)All checks passed!$(COLOR_NC)'

# CI/CD commands
.PHONY: ci
ci: clean deps check build ## Run CI pipeline
	@echo '$(COLOR_GREEN)CI pipeline complete!$(COLOR_NC)'

# Utility commands
.PHONY: list
list: ## List all Go files
	@echo '$(COLOR_BLUE)Go files in project:$(COLOR_NC)'
	@echo $(GO_FILES) | tr ' ' '\n'

.PHONY: count
count: ## Count lines of Go code
	@echo '$(COLOR_BLUE)Lines of Go code:$(COLOR_NC)'
	@find . -name '*.go' -type f | xargs wc -l | tail -n 1

# Database commands (placeholder for future use)
.PHONY: db-migrate
db-migrate: ## Run database migrations
	@echo '$(COLOR_YELLOW)Running database migrations...$(COLOR_NC)'
	@echo 'TODO: Implement when database is configured'

.PHONY: db-rollback
db-rollback: ## Rollback database migrations
	@echo '$(COLOR_YELLOW)Rolling back database migrations...$(COLOR_NC)'
	@echo 'TODO: Implement when database is configured'