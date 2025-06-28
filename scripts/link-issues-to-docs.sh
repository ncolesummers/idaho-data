#!/bin/bash

# Script to add documentation links to GitHub issues

# Define issue-to-doc mappings
declare -A issue_doc_map=(
    ["16"]="docs/tasks/story-04-task-01-basic-ci-workflow.md"
    ["17"]="docs/tasks/story-04-task-02-test-coverage-jobs.md"
    ["18"]="docs/tasks/story-04-task-03-golangci-lint-pipeline.md"
    ["19"]="docs/tasks/story-04-task-04-matrix-builds.md"
    ["20"]="docs/tasks/story-04-task-05-branch-protection.md"
    ["21"]="docs/tasks/story-06-task-01-comprehensive-readme.md"
    ["22"]="docs/tasks/story-06-task-02-contributing-guidelines.md"
)

# Add documentation reference to each issue
for issue in "${!issue_doc_map[@]}"; do
    doc_path="${issue_doc_map[$issue]}"
    
    if [ -f "$doc_path" ]; then
        echo "Updating issue #$issue with link to $doc_path"
        
        # Add a comment with the documentation link
        gh issue comment $issue --body "## 📚 Detailed Implementation Guide

This task has a detailed implementation guide available at: [\`$doc_path\`](https://github.com/ncolesummers/idaho-data/blob/main/$doc_path)

The guide includes:
- Step-by-step instructions
- Code examples and templates
- Configuration samples
- Best practices and tips"
    else
        echo "Warning: Documentation file $doc_path not found for issue #$issue"
    fi
done

echo "✅ Finished updating issues with documentation links"