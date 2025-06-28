# Branch Protection Implementation Guide

## Related GitHub Issue
[#20 - Configure VS Code settings for Go development](https://github.com/ncolesummers/idaho-data/issues/20)

## Setting Up Branch Protection

### 1. Navigate to Branch Protection Settings
1. Go to Settings → Branches
2. Click "Add rule" under Branch protection rules

### 2. Configure Main Branch Protection

**Branch name pattern:** `main`

**Protection settings:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: 1
  - ✅ Dismiss stale pull request approvals
  - ✅ Require review from CODEOWNERS
- ✅ Require status checks to pass
  - ✅ Require branches to be up to date
  - **Required checks:** `build`, `test`, `lint`
- ✅ Require conversation resolution
- ✅ Include administrators
- ✅ Restrict who can push (optional)

### 3. Configure Develop Branch Protection

**Branch name pattern:** `develop`

**Protection settings:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: 1
- ✅ Require status checks to pass
  - **Required checks:** `build`, `test`
- ✅ Automatically delete head branches

### 4. Set Up CODEOWNERS

Copy [`docs/templates/configs/CODEOWNERS`](../templates/configs/CODEOWNERS) to `.github/CODEOWNERS` and customize:

```
# Global owners
* @teamlead @senior-dev

# Specific areas
/api/ @backend-team
/docs/ @docs-team
/.github/ @devops-team
```

## Branch Strategy

### Main Branches
- **main**: Production-ready code
- **develop**: Integration branch

### Feature Branches
- **feature/**: New features
- **fix/**: Bug fixes
- **hotfix/**: Emergency fixes
- **chore/**: Maintenance tasks

### Workflow Example
```bash
# Create feature branch
git checkout -b feature/add-user-api develop

# Work and commit
git add .
git commit -m "feat: add user API endpoint"

# Push and create PR
git push origin feature/add-user-api
# Create PR via GitHub UI or CLI
```

## GitHub CLI Commands

### Create PR with Protection
```bash
# Create PR that respects branch protection
gh pr create --base develop --title "Add user API" --body "Implements user CRUD operations"

# Check PR status
gh pr status

# View required checks
gh pr checks
```

### Emergency Procedures

For critical hotfixes when normal process is too slow:

1. **Create hotfix branch from main**
```bash
git checkout -b hotfix/critical-bug main
```

2. **Apply minimal fix**
3. **Create expedited PR**
```bash
gh pr create --base main --title "HOTFIX: Critical bug" --label "hotfix,urgent"
```

4. **Get emergency approval**
5. **Admin merge if necessary** (Settings → Branches → main → Edit → Allow force pushes)

## Automation Rules

### Auto-merge for Dependabot
```yaml
# .github/auto-merge.yml
- match:
    dependency_type: "development"
    update_type: "semver:patch"
```

### Branch Naming Enforcement
```yaml
# .github/workflows/branch-name.yml
name: Branch Name Check
on: pull_request

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Check branch name
        run: |
          branch=${GITHUB_HEAD_REF}
          if [[ ! "$branch" =~ ^(feature|fix|hotfix|chore)/.+ ]]; then
            echo "Branch name must start with feature/, fix/, hotfix/, or chore/"
            exit 1
          fi
```

## Best Practices

1. **Never bypass protection** unless it's a true emergency
2. **Keep PRs small** for easier reviews
3. **Update branch** before merging to avoid conflicts
4. **Use draft PRs** for work in progress
5. **Link issues** in PR descriptions

## Monitoring

- Review Settings → Branches regularly
- Check Insights → Network for branch visualization
- Monitor failed status checks in Actions tab
- Track PR metrics in Insights → Pull requests