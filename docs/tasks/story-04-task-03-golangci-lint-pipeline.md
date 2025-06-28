# Golangci-lint Pipeline Implementation Guide

## Related GitHub Issue
[#18 - Configure golangci-lint in CI pipeline](https://github.com/ncolesummers/idaho-data/issues/18)

## Implementation Steps

### 1. Create Linting Configuration
Copy [`docs/templates/configs/golangci.yml`](../templates/configs/golangci.yml) to `.golangci.yml` in your project root

### 2. Add Lint Job to CI Workflow

Add this job to `.github/workflows/ci.yml`:

```yaml
lint:
  name: Lint
  runs-on: ubuntu-latest
  
  steps:
  - name: Checkout code
    uses: actions/checkout@v4
    
  - name: Set up Go
    uses: actions/setup-go@v5
    with:
      go-version: '1.21'
      
  - name: Run golangci-lint
    uses: golangci/golangci-lint-action@v6
    with:
      version: v1.59.1
      args: --timeout=10m --config=.golangci.yml
```

### 3. Install Locally

```bash
# macOS
brew install golangci-lint

# Linux/Windows
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.59.1

# Verify installation
golangci-lint --version
```

### 4. Add to Makefile

```makefile
.PHONY: lint
lint:
	@golangci-lint run ./...

.PHONY: lint-fix
lint-fix:
	@golangci-lint run --fix ./...
```

### 5. Configure VS Code

Add to `.vscode/settings.json`:
```json
{
  "go.lintTool": "golangci-lint",
  "go.lintFlags": ["--config=.golangci.yml"]
}
```

## Common Linters Explained

- **govet**: Examines Go source code for suspicious constructs
- **errcheck**: Ensures error return values are checked
- **staticcheck**: Advanced static analysis (like `go vet` on steroids)
- **gosimple**: Suggests code simplifications
- **gofmt**: Enforces standard Go formatting
- **goimports**: Manages import statements
- **gosec**: Security-focused linter
- **misspell**: Catches common spelling mistakes

## Fixing Common Issues

### Unchecked Errors
```go
// Bad
_ = json.NewEncoder(w).Encode(data)

// Good
if err := json.NewEncoder(w).Encode(data); err != nil {
    log.Printf("failed to encode: %v", err)
}
```

### Ineffectual Assignment
```go
// Bad
result, err := doSomething()
result, err = doSomethingElse() // err from first call lost

// Good
result, err := doSomething()
if err != nil {
    return err
}
result, err = doSomethingElse()
```

### Shadow Variables
```go
// Bad
err := doSomething()
if true {
    err := doSomethingElse() // shadows outer err
}

// Good
err := doSomething()
if true {
    err2 := doSomethingElse()
}
```

## Pre-commit Hook Setup

Create `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/golangci/golangci-lint
    rev: v1.59.1
    hooks:
      - id: golangci-lint
```

Install:
```bash
pip install pre-commit
pre-commit install
```

## Performance Tips

- Use `--fast` flag for quick checks during development
- Exclude vendor directory in configuration
- Run specific linters: `golangci-lint run --disable-all --enable=govet,errcheck`
- Cache results: `golangci-lint cache clean` to clear