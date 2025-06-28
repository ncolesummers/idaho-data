# Matrix Builds Implementation Guide

## Related GitHub Issue
[#19 - Set up pre-commit hooks for code quality](https://github.com/ncolesummers/idaho-data/issues/19)

## Matrix Build Configuration

### 1. Add Matrix Strategy to CI Workflow

Update `.github/workflows/ci.yml`:

```yaml
jobs:
  build:
    name: Build
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        go-version: ['1.20', '1.21', '1.22']
      fail-fast: false  # Continue other jobs if one fails
      
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Go ${{ matrix.go-version }}
      uses: actions/setup-go@v5
      with:
        go-version: ${{ matrix.go-version }}
        
    - name: Cache Go modules
      uses: actions/cache@v4
      with:
        path: ~/go/pkg/mod
        key: ${{ runner.os }}-go-${{ matrix.go-version }}-${{ hashFiles('**/go.sum') }}
        restore-keys: |
          ${{ runner.os }}-go-${{ matrix.go-version }}-
          
    - name: Build
      run: go build -v ./...
      
    - name: Test
      run: go test -v -short ./...
```

### 2. Exclude Specific Combinations

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    go-version: ['1.20', '1.21', '1.22']
    exclude:
      - os: macos-latest
        go-version: '1.20'  # Example: Skip Go 1.20 on macOS
```

### 3. Include Additional Configurations

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    go-version: ['1.21', '1.22']
    include:
      - os: ubuntu-latest
        go-version: '1.22'
        race: true  # Add race detection for this combo
```

### 4. Add Summary Job

```yaml
summary:
  name: CI Summary
  runs-on: ubuntu-latest
  needs: [build, test, lint]
  if: always()
  
  steps:
  - name: Check results
    run: |
      if [[ "${{ needs.build.result }}" == "failure" ]]; then
        echo "Build failed"
        exit 1
      fi
      echo "All checks passed!"
```

## OS-Specific Considerations

### Windows
```yaml
- name: Windows-specific setup
  if: runner.os == 'Windows'
  run: |
    echo "Running on Windows"
    # Windows-specific commands
```

### macOS
```yaml
- name: macOS-specific setup
  if: runner.os == 'macOS'
  run: |
    echo "Running on macOS"
    # macOS-specific commands
```

### Linux
```yaml
- name: Linux-specific setup
  if: runner.os == 'Linux'
  run: |
    echo "Running on Linux"
    # Linux-specific commands
```

## Testing Matrix Builds Locally

### Using Docker for Linux Testing
```bash
# Test with Go 1.22 on Linux
docker run --rm -v "$PWD":/app -w /app golang:1.22-alpine go test ./...

# Test with Go 1.21
docker run --rm -v "$PWD":/app -w /app golang:1.21-alpine go test ./...
```

### Using act for Local GitHub Actions
```bash
# Test matrix build locally
act -P ubuntu-latest=golang:1.22
act -P windows-latest=windows:latest
```

## Optimizing Matrix Builds

### 1. Parallel Job Limits
GitHub Actions runs up to 20 jobs in parallel for free accounts.

### 2. Conditional Matrix
```yaml
strategy:
  matrix:
    os: ${{ github.event_name == 'push' && fromJSON('["ubuntu-latest"]') || fromJSON('["ubuntu-latest", "windows-latest", "macos-latest"]') }}
```

### 3. Caching Strategy
- Use OS and Go version in cache keys
- Share caches between similar configurations
- Clear caches periodically

## Common Issues

**Path Separators**
```go
// Use filepath package for cross-platform paths
path := filepath.Join("dir", "subdir", "file.go")
```

**Line Endings**
```bash
# .gitattributes
*.go text eol=lf
*.mod text eol=lf
*.sum text eol=lf
```

**Shell Commands**
```yaml
# Use shell parameter for consistency
- name: Run script
  shell: bash
  run: ./script.sh
```