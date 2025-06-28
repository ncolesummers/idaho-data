# Idaho Data Standardization API

A REST API for retrieving and analyzing public employee salary data from the Idaho State Controller's transparency portal.

## Project Status

🚧 Under Development - Sprint 0 in progress

## Quick Start

```bash
# Build the project
make build

# Run the server
make run

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
```

## Available Commands

Run `make help` to see all available commands. Common commands include:

```bash
# Development
make build          # Build the binary
make run            # Build and run the application
make test           # Run all tests
make test-coverage  # Run tests with coverage
make fmt            # Format all Go files
make lint           # Run golangci-lint
make check          # Run all checks (fmt, vet, lint, test)

# Dependencies
make deps           # Download dependencies
make deps-tidy      # Run go mod tidy

# Docker
make docker-build   # Build Docker image
make docker-run     # Run Docker container

# Other
make clean          # Remove build artifacts
make help           # Display all available commands
```

## Project Structure

```
.
├── api/           # OpenAPI specifications
├── cmd/           # Application entrypoints
│   └── server/    # Main server application
├── internal/      # Private application code
│   ├── config/    # Configuration management
│   ├── database/  # Database connections
│   ├── handlers/  # HTTP handlers
│   ├── models/    # Data models
│   └── services/  # Business logic
├── pkg/           # Public packages
│   └── validator/ # Validation utilities
├── migrations/    # Database migrations
└── tests/         # Test files
    ├── integration/
    └── unit/
```

## Development

See [docs/](docs/) for detailed documentation and [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.