# Basic CI Workflow Implementation Guide

## Related GitHub Issue
[#16 - Create basic GitHub Actions CI workflow](https://github.com/ncolesummers/idaho-data/issues/16)

## Implementation Steps

### 1. Create Directory Structure
```bash
mkdir -p .github/workflows
```

### 2. Create Workflow File
Copy the template from [`docs/templates/ci/basic-workflow.yml`](../templates/ci/basic-workflow.yml) to `.github/workflows/ci.yml`

### 3. Customize for Your Project
- Update `go-version` to match your project's Go version
- Modify branch names in the `on:` section if needed
- Add any project-specific build steps

### 4. Test Locally (Optional)
```bash
# Install act tool
brew install act  # macOS
# or see https://github.com/nektos/act for other OS

# Test the workflow
act -n  # Dry run
act     # Actually run
```

### 5. Add Status Badge
After the workflow runs once, add this to your README:
```markdown
![CI](https://github.com/ncolesummers/idaho-data/workflows/CI/badge.svg)
```

## Troubleshooting

**Workflow not triggering?**
- Verify file location: `.github/workflows/ci.yml`
- Check YAML syntax at https://www.yamllint.com/
- Ensure branch names match your repository

**Permission errors?**
- Go to Settings → Actions → General
- Enable "Allow all actions and reusable workflows"

**Go version mismatch?**
- Check your `go.mod` file for the correct version
- Update the workflow's `go-version` field

## Additional Resources
- [GitHub Actions Go Setup](https://github.com/actions/setup-go)
- [Workflow syntax reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)