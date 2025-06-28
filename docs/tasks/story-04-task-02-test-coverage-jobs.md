# Test Coverage Jobs Implementation Guide

## Related GitHub Issue
[#17 - Add test and coverage jobs to CI workflow](https://github.com/ncolesummers/idaho-data/issues/17)

## Implementation Steps

### 1. Add Test Job to Workflow
Copy the template from [`docs/templates/ci/test-coverage-job.yml`](../templates/ci/test-coverage-job.yml) and add it to your `.github/workflows/ci.yml`

### 2. Set Up Codecov Integration

#### Create Codecov Account
1. Go to [codecov.io](https://codecov.io)
2. Sign in with GitHub
3. Add your repository
4. Copy the upload token (optional for public repos)

#### Add Codecov Configuration
Copy [`docs/templates/configs/codecov.yml`](../templates/configs/codecov.yml) to your project root

#### Add Secret (Private Repos Only)
```bash
# In GitHub: Settings → Secrets → Actions → New repository secret
# Name: CODECOV_TOKEN
# Value: [your codecov token]
```

### 3. Update .gitignore
```gitignore
# Test coverage
coverage.txt
coverage.html
*.out
```

### 4. Add Coverage Badge to README
```markdown
[![codecov](https://codecov.io/gh/ncolesummers/idaho-data/branch/main/graph/badge.svg)](https://codecov.io/gh/ncolesummers/idaho-data)
```

## Local Testing

### Run Tests with Coverage
```bash
# Basic coverage
go test -coverprofile=coverage.txt ./...

# With race detection
go test -race -coverprofile=coverage.txt -covermode=atomic ./...

# Generate HTML report
go tool cover -html=coverage.txt -o coverage.html
open coverage.html
```

### Coverage by Package
```bash
go test -cover ./...
```

## Writing Testable Code

### Good Practices
- Keep functions small and focused
- Use interfaces for dependencies
- Avoid package-level variables
- Return errors instead of panicking

### Example Test Structure
```go
func TestFeature(t *testing.T) {
    t.Run("successful case", func(t *testing.T) {
        // Arrange
        input := "test"
        expected := "result"
        
        // Act
        result := Feature(input)
        
        // Assert
        if result != expected {
            t.Errorf("got %v, want %v", result, expected)
        }
    })
    
    t.Run("error case", func(t *testing.T) {
        // Test error conditions
    })
}
```

## Troubleshooting

**Tests timing out?**
- Increase timeout: `go test -timeout 60s ./...`
- Check for infinite loops or blocking operations

**Coverage not showing?**
- Ensure tests actually execute the code
- Check that coverage file is generated
- Verify Codecov integration is working

**Race conditions detected?**
- Use sync primitives (mutex, channels)
- Avoid shared state
- Run tests with `-race` flag regularly