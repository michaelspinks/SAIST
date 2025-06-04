#!/bin/bash
# entrypoint.sh

# Exit if any command fails (good practice)
set -e

echo "🛡️ SAIST Security Scanner Starting..."

# GitHub Actions automatically sets these environment variables
# INPUT_* variables come from the inputs in action.yml
GITHUB_TOKEN="$INPUT_GITHUB_TOKEN"
OPENAI_API_KEY="$INPUT_OPENAI_API_KEY"
SCAN_MODE="$INPUT_SCAN_MODE"
FAIL_ON_HIGH="$INPUT_FAIL_ON_HIGH"

echo "📋 Configuration:"
echo "  - Scan mode: $SCAN_MODE"
echo "  - Fail on high: $FAIL_ON_HIGH"
echo "  - Event: $GITHUB_EVENT_NAME"

# Check if this is a pull request
if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    echo "🔍 This is a pull request - scanning changed files"
    
    # Get information about the PR from GitHub's event data
    PR_NUMBER=$(jq -r .pull_request.number "$GITHUB_EVENT_PATH")
    BASE_SHA=$(jq -r .pull_request.base.sha "$GITHUB_EVENT_PATH")
    HEAD_SHA=$(jq -r .pull_request.head.sha "$GITHUB_EVENT_PATH")
    
    echo "  - PR #$PR_NUMBER"
    echo "  - Comparing $BASE_SHA to $HEAD_SHA"
    
    # Get the list of changed files
    git fetch origin "$BASE_SHA" "$HEAD_SHA"
    CHANGED_FILES=$(git diff --name-only "$BASE_SHA..$HEAD_SHA" | grep -E '\.(py|js|ts|java|php|rb|go|cs|cpp|c)$' || true)
    
    if [ -z "$CHANGED_FILES" ]; then
        echo "ℹ️  No code files changed - skipping scan"
        echo "findings-count=0" >> "$GITHUB_OUTPUT"
        echo "high-count=0" >> "$GITHUB_OUTPUT"
        exit 0
    fi
    
    echo "📁 Files to scan:"
    echo "$CHANGED_FILES"
else
    echo "🔍 Not a PR - doing full repository scan"
    CHANGED_FILES=""
fi

# Run SAIST (mock for now)
echo "🤖 Running SAIST analysis..."

# For now, we'll simulate SAIST output
# Later, replace this with actual SAIST command
FINDINGS_COUNT=$((RANDOM % 5))  # Random number 0-4
HIGH_COUNT=$((RANDOM % 3))      # Random number 0-2

echo "📊 Mock scan results:"
echo "  - Total findings: $FINDINGS_COUNT"
echo "  - High severity: $HIGH_COUNT"

# Set GitHub Action outputs (other steps can read these)
echo "findings-count=$FINDINGS_COUNT" >> "$GITHUB_OUTPUT"
echo "high-count=$HIGH_COUNT" >> "$GITHUB_OUTPUT"

# Create a simple report
REPORT="## 🛡️ SAIST Security Scan Results

### Summary
- **Total Findings:** $FINDINGS_COUNT
- **High Severity:** $HIGH_COUNT

"

if [ "$HIGH_COUNT" -gt 0 ] && [ "$FAIL_ON_HIGH" = "true" ]; then
    REPORT="$REPORT
❌ **Build Failed**: High-severity security issues found.
"
    SHOULD_FAIL=true
else
    REPORT="$REPORT
✅ **Build Passed**: No critical security issues blocking deployment.
"
    SHOULD_FAIL=false
fi

REPORT="$REPORT
---
*🤖 Powered by [SAIST](https://github.com/punk-security/SAIST)*"

# Post comment to PR (if this is a PR)
if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    echo "💬 Posting results to PR..."
    
    # Use GitHub API to post comment
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         -H "Accept: application/vnd.github.v3+json" \
         -X POST \
         "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
         -d "{\"body\": $(echo "$REPORT" | jq -R -s .)}"
    
    echo "✅ Comment posted to PR #$PR_NUMBER"
fi

# Fail the build if needed
if [ "$SHOULD_FAIL" = true ]; then
    echo "❌ Failing build due to high-severity findings"
    exit 1
else
    echo "✅ Security scan completed successfully"
    exit 0
fi