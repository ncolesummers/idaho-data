# Implementation Guides

This directory contains detailed implementation guides and reusable templates for Sprint 0 tasks.

## Quick Links to GitHub Issues

| Issue | Title | Implementation Guide |
|-------|-------|---------------------|
| [#16](https://github.com/ncolesummers/idaho-data/issues/16) | Create basic GitHub Actions CI workflow | [Basic CI Setup](tasks/story-04-task-01-basic-ci-workflow.md) |
| [#17](https://github.com/ncolesummers/idaho-data/issues/17) | Add test and coverage jobs to CI workflow | [Test Coverage](tasks/story-04-task-02-test-coverage-jobs.md) |
| [#18](https://github.com/ncolesummers/idaho-data/issues/18) | Configure golangci-lint in CI pipeline | [Linting Setup](tasks/story-04-task-03-golangci-lint-pipeline.md) |
| [#19](https://github.com/ncolesummers/idaho-data/issues/19) | Set up pre-commit hooks | [Pre-commit Setup](tasks/story-04-task-04-matrix-builds.md) |
| [#20](https://github.com/ncolesummers/idaho-data/issues/20) | Configure VS Code settings | [VS Code Config](tasks/story-04-task-05-branch-protection.md) |
| [#21](https://github.com/ncolesummers/idaho-data/issues/21) | Create comprehensive README | [README Guide](tasks/story-06-task-01-comprehensive-readme.md) |
| [#22](https://github.com/ncolesummers/idaho-data/issues/22) | Create CONTRIBUTING.md | [Contributing Guide](tasks/story-06-task-02-contributing-guidelines.md) |

## Reusable Templates

### CI/CD Templates
- [Basic CI Workflow](templates/ci/basic-workflow.yml)
- [Test Coverage Job](templates/ci/test-coverage-job.yml)

### Configuration Templates
- [golangci-lint config](templates/configs/golangci.yml)
- [Codecov config](templates/configs/codecov.yml)
- [CODEOWNERS template](templates/configs/CODEOWNERS)

## Using the Templates

1. **For CI/CD**: Copy the workflow templates from `templates/ci/` to `.github/workflows/`
2. **For Linting**: Copy `templates/configs/golangci.yml` to `.golangci.yml` in your project root
3. **For Coverage**: Copy `templates/configs/codecov.yml` to `codecov.yml` in your project root
4. **For Code Ownership**: Copy `templates/configs/CODEOWNERS` to `.github/CODEOWNERS` and update team names

## Best Practices

- Always test configurations locally before committing
- Update Go versions in CI templates to match your project requirements
- Customize linting rules based on your team's coding standards
- Set appropriate coverage thresholds for your project maturity