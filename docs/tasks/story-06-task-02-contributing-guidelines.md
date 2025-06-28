# Contributing Guidelines Implementation Guide

## Related GitHub Issue
[#22 - Create CONTRIBUTING.md with guidelines](https://github.com/ncolesummers/idaho-data/issues/22)

## CONTRIBUTING.md Template

```markdown
# Contributing to Idaho Data Standardization API

Thank you for your interest in contributing! We welcome contributions of all kinds.

## Code of Conduct

By participating, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Issues

Before creating an issue:
1. Check existing issues to avoid duplicates
2. Use issue templates when available
3. Provide clear reproduction steps
4. Include system information

### Suggesting Features

1. Check the roadmap and existing feature requests
2. Open a discussion first for major changes
3. Explain the use case and benefits
4. Consider implementation complexity

### Submitting Code

#### Setup Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/YOUR-USERNAME/idaho-data.git
cd idaho-data

# Add upstream remote
git remote add upstream https://github.com/ncolesummers/idaho-data.git

# Install dependencies
go mod download

# Install development tools
make install-tools
```

#### Development Workflow

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name develop
   ```

2. **Make changes**
   - Write clean, documented code
   - Follow existing patterns
   - Add tests for new functionality

3. **Test your changes**
   ```bash
   make test
   make lint
   ```

4. **Commit with conventional commits**
   ```bash
   git commit -m "feat: add new endpoint for salary analytics"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, semicolons, etc)
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add filter by department to salary endpoint
fix: correct date parsing in CSV import
docs: update API authentication section
```

### Pull Request Process

1. **Before submitting:**
   - Update documentation if needed
   - Add tests for new features
   - Ensure all tests pass
   - Run linter and fix issues
   - Update CHANGELOG.md

2. **PR description should include:**
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Related issue numbers

3. **Review process:**
   - At least one approval required
   - CI checks must pass
   - Address review feedback promptly
   - Keep PR focused and small

### Code Standards

#### Go Style
- Follow [Effective Go](https://golang.org/doc/effective_go)
- Use `gofmt` and `goimports`
- Write idiomatic Go code
- Prefer clarity over cleverness

#### Testing
- Aim for 80% code coverage
- Write table-driven tests
- Test edge cases
- Use meaningful test names

#### Documentation
- Document all exported functions
- Include examples in godoc
- Keep README up to date
- Document breaking changes

### API Design Guidelines

- Follow RESTful principles
- Use consistent naming
- Version the API properly
- Return appropriate status codes
- Include helpful error messages

## Development Tips

### Running Tests
```bash
# All tests
make test

# Specific package
go test -v ./pkg/...

# With coverage
make test-coverage
```

### Debugging
```bash
# Run with debug logging
LOG_LEVEL=debug go run cmd/api/main.go

# Use delve debugger
dlv debug cmd/api/main.go
```

### Database Migrations
```bash
# Create new migration
make migration name=add_user_table

# Run migrations
make migrate-up

# Rollback
make migrate-down
```

## Getting Help

- Join our [Discord server](https://discord.gg/idaho-data)
- Check the [documentation](https://docs.idaho-data.dev)
- Ask in GitHub Discussions
- Email: contribute@idaho-data.dev

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project website

Thank you for contributing! 🎉
```

## Additional Files to Create

### Code of Conduct
Create `CODE_OF_CONDUCT.md` using [Contributor Covenant](https://www.contributor-covenant.org/)

### Issue Templates
Already configured in `.github/ISSUE_TEMPLATE/`

### PR Template
Already exists at `.github/pull_request_template.md`

### CHANGELOG Format
```markdown
# Changelog

## [Unreleased]

### Added
- New features

### Changed
- Changes to existing features

### Fixed
- Bug fixes

### Removed
- Removed features

## [1.0.0] - 2024-01-01

### Added
- Initial release
```

## Maintenance Tips

1. **Keep it concise** - Long guidelines discourage participation
2. **Be welcoming** - Encourage first-time contributors
3. **Provide examples** - Show don't just tell
4. **Update regularly** - Keep in sync with project practices
5. **Link resources** - Don't duplicate existing docs