#!/bin/bash
#
# GitHub Issues ↔ feature_list.json Sync Utility
# 
# This script syncs GitHub Issues to local feature tracking files.
# GitHub Issues are the source of truth.
#
# Usage:
#   ./github-sync.sh pull              # GitHub → local files
#   ./github-sync.sh push-status       # Update issue labels based on local verification
#   ./github-sync.sh close-verified    # Close issues that have been verified locally
#   ./github-sync.sh status            # Show sync status
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - jq installed
#
# Label Conventions:
#   Category:  category:authentication, category:user-management, etc.
#   Priority:  priority:1, priority:2, priority:3 (1=highest)
#   Status:    status:verified, status:in-progress, status:blocked
#   Type:      type:feature (to distinguish from bugs, docs, etc.)
#

set -e

# Configuration
REPO="${GITHUB_REPO:-}"  # owner/repo format, or auto-detect from git remote
FEATURE_LABEL="type:feature"
VERIFIED_LABEL="status:verified"

# Auto-detect repo if not set
if [ -z "$REPO" ]; then
    REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
    if [ -z "$REPO" ]; then
        echo "Error: Could not detect GitHub repo. Set GITHUB_REPO=owner/repo"
        exit 1
    fi
fi

echo "Repository: $REPO"

# ============================================
# PULL: GitHub Issues → Local Files
# ============================================
pull_issues() {
    echo "Pulling issues from GitHub..."
    
    # Fetch all feature issues (open and closed)
    gh issue list \
        --repo "$REPO" \
        --label "$FEATURE_LABEL" \
        --state all \
        --limit 500 \
        --json number,title,body,state,labels,milestone,createdAt,closedAt \
        > .github-issues-raw.json
    
    ISSUE_COUNT=$(jq 'length' .github-issues-raw.json)
    echo "Found $ISSUE_COUNT feature issues"
    
    # Transform to feature_list.json format
    jq '
    {
        project_name: env.REPO,
        created_at: now | todate,
        last_updated: now | todate,
        source: "github",
        github_repo: env.REPO,
        _readme: "Synced from GitHub Issues. Do not edit directly - changes will be overwritten on next sync.",
        summary: {
            total_features: length,
            completed: [.[] | select(.state == "CLOSED")] | length,
            remaining: [.[] | select(.state == "OPEN")] | length,
            archive_file: ".claude/archives/completed_features.json"
        },
        features: [
            .[] | {
                id: .number,
                github_issue: .number,
                github_url: "https://github.com/\(env.REPO)/issues/\(.number)",
                category: (
                    [.labels[].name | select(startswith("category:"))] | 
                    first | 
                    if . then gsub("category:"; "") else "uncategorized" end
                ),
                priority: (
                    [.labels[].name | select(startswith("priority:"))] | 
                    first | 
                    if . then gsub("priority:"; "") | tonumber else 99 end
                ),
                title: .title,
                description: (.body // "No description"),
                verification_steps: (
                    if .body then
                        (.body | capture("## Verification Steps\\n(?<steps>[\\s\\S]*?)(?=\\n## |$)").steps // null) |
                        if . then split("\n") | map(select(startswith("- "))) | map(gsub("^- "; "")) else [] end
                    else []
                    end
                ),
                dependencies: (
                    if .body then
                        (.body | capture("## Dependencies\\n(?<deps>[\\s\\S]*?)(?=\\n## |$)").deps // null) |
                        if . then split("\n") | map(select(startswith("- #"))) | map(gsub("^- #"; "") | tonumber) else [] end
                    else []
                    end
                ),
                milestone: (.milestone.title // null),
                passes: (.state == "CLOSED"),
                verified: ([.labels[].name | select(. == "status:verified")] | length > 0),
                implemented_at: .closedAt,
                verified_at: (
                    if ([.labels[].name | select(. == "status:verified")] | length > 0) 
                    then .closedAt 
                    else null 
                    end
                ),
                git_commit: null
            }
        ] | sort_by(.priority, .id)
    }
    ' .github-issues-raw.json > feature_list.json
    
    # Generate feature_index.json
    jq '
    {
        _readme: "Synced from GitHub Issues. Source of truth: GitHub.",
        project_name: .project_name,
        github_repo: .github_repo,
        last_updated: .last_updated,
        last_sync: now | todate,
        totals: {
            total: .summary.total_features,
            completed: .summary.completed,
            remaining: .summary.remaining,
            percent_complete: ((.summary.completed / .summary.total_features * 100) | floor)
        },
        next_priority: (
            [.features[] | select(.passes == false)] | 
            sort_by(.priority, .id) | 
            first |
            if . then {id: .id, title: .title, category: .category, github_url: .github_url} else null end
        ),
        blockers: [.features[] | select(.passes == false) | select(.dependencies | length > 0) | 
            select([.dependencies[] as $d | .passes] | all | not) |
            {id: .id, title: .title, blocked_by: .dependencies}
        ],
        categories: (
            .features | group_by(.category) | map({
                key: .[0].category,
                value: {
                    total: length,
                    done: [.[] | select(.passes)] | length
                }
            }) | from_entries
        )
    }
    ' feature_list.json > feature_index.json
    
    # Update claude-progress.txt header
    update_progress_header
    
    # Cleanup
    rm -f .github-issues-raw.json
    
    echo "✓ Synced $ISSUE_COUNT issues to local files"
    echo "  - feature_list.json"
    echo "  - feature_index.json"
    echo "  - claude-progress.txt (header updated)"
}

# ============================================
# UPDATE PROGRESS HEADER
# ============================================
update_progress_header() {
    TOTAL=$(jq '.summary.total_features' feature_list.json)
    DONE=$(jq '.summary.completed' feature_list.json)
    REMAINING=$(jq '.summary.remaining' feature_list.json)
    PERCENT=$((DONE * 100 / TOTAL))
    
    NEXT_ID=$(jq -r '.next_priority.id // "none"' feature_index.json)
    NEXT_TITLE=$(jq -r '.next_priority.title // "All complete!"' feature_index.json)
    
    # If progress file doesn't exist, create it
    if [ ! -f claude-progress.txt ]; then
        cat > claude-progress.txt << PROGRESS_EOF
# Project: $REPO
# Last Updated: $(date -u +"%Y-%m-%d %H:%M UTC")
# Source: GitHub Issues (synced)

# ═══════════════════════════════════════════════════════════════════
#  QUICK STATUS — Read this section at every session start
# ═══════════════════════════════════════════════════════════════════
#
#  Total: $TOTAL | Done: $DONE | Remaining: $REMAINING | Progress: $PERCENT%
#
#  NEXT FEATURE: #$NEXT_ID - $NEXT_TITLE
#  BLOCKERS: See feature_index.json
#  KNOWN ISSUES: None
#
#  Source of Truth: GitHub Issues
#  Sync Command: ./github-sync.sh pull
#  GitHub: https://github.com/$REPO/issues
#
# ═══════════════════════════════════════════════════════════════════

## Session History

(No sessions recorded yet)

---
PROGRESS_EOF
    else
        # Update just the header (first 25 lines)
        # This is a simplified version - in production you'd want sed/awk
        echo "Note: claude-progress.txt header should be manually updated"
        echo "  Total: $TOTAL | Done: $DONE | Remaining: $REMAINING | Progress: $PERCENT%"
        echo "  Next: #$NEXT_ID - $NEXT_TITLE"
    fi
}

# ============================================
# PUSH STATUS: Update GitHub labels from local
# ============================================
push_status() {
    echo "Pushing verification status to GitHub..."
    
    # Find locally verified features that don't have the label
    jq -r '.features[] | select(.verified == true) | select(.passes == true) | .github_issue' feature_list.json | \
    while read -r ISSUE_NUM; do
        echo "Adding verified label to #$ISSUE_NUM"
        gh issue edit "$ISSUE_NUM" --repo "$REPO" --add-label "$VERIFIED_LABEL" 2>/dev/null || true
    done
    
    echo "✓ Status pushed to GitHub"
}

# ============================================
# CLOSE VERIFIED: Close issues verified locally
# ============================================
close_verified() {
    echo "Closing verified issues on GitHub..."
    
    # Find verified features that are still open
    jq -r '.features[] | select(.verified == true) | select(.passes == false) | .github_issue' feature_list.json | \
    while read -r ISSUE_NUM; do
        echo "Closing #$ISSUE_NUM (verified locally)"
        gh issue close "$ISSUE_NUM" --repo "$REPO" --comment "Verified and closed by @verifier agent." 2>/dev/null || true
    done
    
    echo "✓ Verified issues closed"
}

# ============================================
# STATUS: Show sync status
# ============================================
show_status() {
    echo "=== GitHub Sync Status ==="
    echo ""
    echo "Repository: $REPO"
    echo "Local files:"
    
    if [ -f feature_list.json ]; then
        TOTAL=$(jq '.summary.total_features' feature_list.json)
        DONE=$(jq '.summary.completed' feature_list.json)
        REMAINING=$(jq '.summary.remaining' feature_list.json)
        LAST_SYNC=$(jq -r '.last_updated' feature_list.json)
        echo "  feature_list.json: $TOTAL features ($DONE done, $REMAINING remaining)"
        echo "  Last sync: $LAST_SYNC"
    else
        echo "  feature_list.json: NOT FOUND"
    fi
    
    if [ -f feature_index.json ]; then
        echo "  feature_index.json: OK"
    else
        echo "  feature_index.json: NOT FOUND"
    fi
    
    echo ""
    echo "GitHub status:"
    OPEN_COUNT=$(gh issue list --repo "$REPO" --label "$FEATURE_LABEL" --state open --json number | jq 'length')
    CLOSED_COUNT=$(gh issue list --repo "$REPO" --label "$FEATURE_LABEL" --state closed --json number | jq 'length')
    echo "  Open feature issues: $OPEN_COUNT"
    echo "  Closed feature issues: $CLOSED_COUNT"
    echo ""
    echo "Run './github-sync.sh pull' to sync from GitHub"
}

# ============================================
# CREATE ISSUE: Create a new feature issue
# ============================================
create_issue() {
    TITLE="$1"
    CATEGORY="${2:-uncategorized}"
    PRIORITY="${3:-3}"
    
    if [ -z "$TITLE" ]; then
        echo "Usage: ./github-sync.sh create 'Feature title' [category] [priority]"
        exit 1
    fi
    
    BODY="## Description

TODO: Describe the feature

## Verification Steps

- Step 1
- Step 2
- Step 3

## Dependencies

(None)
"
    
    gh issue create \
        --repo "$REPO" \
        --title "$TITLE" \
        --body "$BODY" \
        --label "$FEATURE_LABEL" \
        --label "category:$CATEGORY" \
        --label "priority:$PRIORITY"
    
    echo "✓ Issue created. Run './github-sync.sh pull' to update local files."
}

# ============================================
# MAIN
# ============================================
case "${1:-status}" in
    pull)
        pull_issues
        ;;
    push-status)
        push_status
        ;;
    close-verified)
        close_verified
        ;;
    status)
        show_status
        ;;
    create)
        create_issue "$2" "$3" "$4"
        ;;
    *)
        echo "Usage: ./github-sync.sh [pull|push-status|close-verified|status|create]"
        echo ""
        echo "Commands:"
        echo "  pull           - Sync GitHub Issues → local files"
        echo "  push-status    - Add 'verified' label to verified issues"
        echo "  close-verified - Close issues that were verified locally"
        echo "  status         - Show sync status"
        echo "  create         - Create a new feature issue"
        exit 1
        ;;
esac