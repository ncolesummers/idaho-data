# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Idaho Data Standardization API - A REST API for retrieving and analyzing public employee salary data from Idaho's transparency portal. Currently in Sprint 0 (setup phase).

## Essential Commands

### Building and Running
```bash
make build              # Build the binary to bin/idaho-data-api
make run                # Build and run the application (port 8080)
make watch              # Run with file watcher (installs air if needed)
```

### Testing
```bash
make test               # Run all tests
make test-verbose       # Run tests with detailed output
make test-coverage      # Generate coverage report (target: >80%)
make coverage-html      # Generate HTML coverage report
```

### Code Quality
```bash
make fmt                # Format all Go files
make vet                # Run go vet
make lint               # Run golangci-lint (installs if needed)
make check              # Run all checks: fmt, vet, lint, test
```

### Development Workflow
```bash
make deps-tidy          # Clean up go.mod/go.sum
make clean              # Remove build artifacts
make ci                 # Full CI pipeline: clean, deps, check, build
```

## Architecture Overview

### Entry Point
- `cmd/server/main.go`: HTTP server with `/` and `/health` endpoints

### Internal Package Structure
The `internal/` directory contains private application code:
- **handlers**: HTTP request handlers (implement here)
- **services**: Business logic and data processing
- **models**: Data structures and database schemas
- **database**: Connection management and query execution
- **config**: Configuration loading and validation
- **cache**: Caching layer for performance (<200ms response target)
- **data**: Data access layer and repositories
- **events**: Event handling and pub/sub patterns
- **metrics**: Application metrics and monitoring

### Public Packages
The `pkg/` directory contains reusable utilities:
- **validator**: Input validation utilities

### Test Organization
- `tests/unit/`: Unit tests for individual components
- `tests/integration/`: Tests requiring external dependencies
- `tests/e2e/`: Full end-to-end API tests

## Development Approach

### TDD Cycle
1. Write failing test
2. Implement minimal code to pass
3. Refactor while keeping tests green
4. Ensure coverage remains >80%

### Sprint Structure
Project organized into sprints (0-6). Check `docs/tasks/` for current sprint details and task breakdowns. Each task includes acceptance criteria and time estimates.

### GitHub Workflow
- Issues use templates: user-story, task, epic, bug, documentation
- PRs must pass all automated checks
- Link issues to documentation using `scripts/link-issues-to-docs.sh`

## Key Patterns

### Error Handling
Use idiomatic Go error handling with wrapped errors for context.

### API Design
- RESTful endpoints
- Health check at `/health`
- Target <200ms response time for cached queries

### Configuration
Environment-specific configs go in `configs/` directory.

### Database
Migrations will be in `migrations/` directory (not yet implemented).

## Current State

**Sprint 0** - Basic setup complete:
- ✅ Project structure
- ✅ Basic HTTP server
- ✅ Build tooling (Makefile)
- ✅ Documentation framework
- ⏳ Business logic implementation
- ⏳ Database connectivity
- ⏳ API endpoints

## Quick Debugging

### Run Single Test
```bash
go test -v -run TestName ./internal/handlers
```

### Check Module Dependencies
```bash
go mod graph
go mod why <package>
```

### Local Development Server
Default port is 8080. Server provides basic logging to stdout.

## Important Files

- `Makefile`: All build and development commands
- `.editorconfig`: Code formatting rules (tabs for Go)
- `docs/sprint-0-tasks-summary.md`: Current sprint overview
- `docs/tasks/`: Detailed implementation guides

## Development Workflow

### GitHub and Sprint Management
- Our workflow in this repository is to:
  1. Review an open issue using the `gh` CLI
  2. Complete tasks in the current sprint one user story at a time, following all acceptance criteria. Use a new branch for each story
  3. Finish the user story by creating a pull request