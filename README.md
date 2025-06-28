# Idaho Data Standardization API

A REST API for retrieving and analyzing public employee salary data from the Idaho State Controller's transparency portal.

## Project Status

🚧 Under Development - Sprint 0 in progress

## Quick Start

```bash
# Build the project
go build -o bin/server cmd/server/main.go

# Run the server
./bin/server

# Test endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
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