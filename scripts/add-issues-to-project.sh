#!/bin/bash

# Script to add GitHub issues to the project board
# Usage: ./scripts/add-issues-to-project.sh [issue-numbers]
# Example: ./scripts/add-issues-to-project.sh 1,2,3
# If no issue numbers provided, it will add all open issues

PROJECT_NUMBER=3
PROJECT_ID="PVT_kwHOAVwHTc4A8lgA"

echo "🔄 Adding issues to Idaho Government Data Analysis project board..."

if [ -z "$1" ]; then
    echo "📋 Adding all open issues to project board..."
    
    # Get all open issues
    ISSUES=$(gh issue list --state open --json number --jq '.[].number')
    
    for ISSUE in $ISSUES; do
        echo "  → Adding issue #$ISSUE..."
        gh issue edit "$ISSUE" --add-project "$PROJECT_NUMBER" 2>/dev/null || echo "    ⚠️  Issue #$ISSUE may already be in project"
    done
else
    # Add specific issues
    IFS=',' read -ra ISSUE_NUMBERS <<< "$1"
    
    for ISSUE in "${ISSUE_NUMBERS[@]}"; do
        ISSUE=$(echo "$ISSUE" | tr -d ' ')
        echo "  → Adding issue #$ISSUE..."
        gh issue edit "$ISSUE" --add-project "$PROJECT_NUMBER" 2>/dev/null || echo "    ⚠️  Issue #$ISSUE may already be in project or not found"
    done
fi

echo "✅ Done! Check your project board at: https://github.com/users/ncolesummers/projects/3"