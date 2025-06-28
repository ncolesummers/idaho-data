#!/bin/bash

# Script to install and configure pre-commit hooks

echo "🔧 Installing pre-commit..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "📦 pre-commit not found. Installing..."
    
    # Try pip first
    if command -v pip &> /dev/null; then
        pip install pre-commit
    elif command -v pip3 &> /dev/null; then
        pip3 install pre-commit
    elif command -v brew &> /dev/null; then
        brew install pre-commit
    else
        echo "❌ Could not install pre-commit. Please install it manually:"
        echo "   pip install pre-commit"
        echo "   or"
        echo "   brew install pre-commit"
        exit 1
    fi
fi

echo "✅ pre-commit is installed"

# Install the git hook scripts
echo "🔗 Installing git hooks..."
pre-commit install

# Run against all files
echo "🏃 Running pre-commit on all files..."
pre-commit run --all-files || true

echo "✨ Pre-commit setup complete!"
echo ""
echo "Pre-commit will now run automatically before each commit."
echo "To run manually: pre-commit run --all-files"