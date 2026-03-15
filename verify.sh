#!/usr/bin/env bash
set -euo pipefail

#===============================================================================
# TestPilotBot - Claude Code Wrapper
#===============================================================================
#
# Usage:
#   ./verify.sh <jira_ticket> [test_env_url] [figma_url]
#
# Examples:
#   ./verify.sh SATHREE-41816
#   ./verify.sh SATHREE-41816 https://members-test13.seeking.com
#   ./verify.sh SATHREE-41816 https://members-test13.seeking.com "https://figma.com/design/..."
#
# Prerequisites:
#   - Claude Code CLI installed (`claude` command available)
#   - Jira MCP configured (for ticket reading)
#   - Figma MCP configured (for design specs)
#
#===============================================================================

# ── Configuration ─────────────────────────────────────────────────────────────
FE_REPO="${FE_REPO:-/Users/khantopa/dev/sa-v3}"
BE_REPO="${BE_REPO:-/Users/khantopa/dev/seeking}"
QA_REPO="${QA_REPO:-/Users/khantopa/dev/sa-ui-automation}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
REPORTS_DIR="${PROJECT_DIR}/reports"

# ── Argument parsing ──────────────────────────────────────────────────────────
JIRA_TICKET="${1:-}"
TEST_ENV_URL="${2:-}"
FIGMA_URL="${3:-}"

if [[ -z "$JIRA_TICKET" ]]; then
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  TestPilotBot — Pre-Release Verification Agent              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Usage: ./verify.sh <jira_ticket> [test_env_url] [figma_url]"
    echo ""
    echo "Arguments:"
    echo "  jira_ticket   Jira ticket ID (required) e.g., SATHREE-41816"
    echo "  test_env_url  Test environment URL (optional — will ask if omitted)"
    echo "  figma_url     Figma design URL (optional — will ask if omitted)"
    echo ""
    echo "Examples:"
    echo "  ./verify.sh SATHREE-41816"
    echo "  ./verify.sh SATHREE-41816 https://members-test13.seeking.com"
    echo ""
    echo "Configuration (set via env vars or edit this script):"
    echo "  FE_REPO=$FE_REPO"
    echo "  BE_REPO=$BE_REPO"
    echo "  QA_REPO=$QA_REPO"
    exit 1
fi

# ── Pre-flight checks ─────────────────────────────────────────────────────────
echo "── Pre-flight checks ──────────────────────────────────"

if ! command -v claude &>/dev/null; then
    echo "ERROR: 'claude' CLI not found. Install Claude Code first."
    echo "  npm install -g @anthropic-ai/claude-code"
    exit 1
fi

echo "  ✓ Claude Code CLI found"

REPOS_AVAILABLE=()
for repo_var in FE_REPO BE_REPO QA_REPO; do
    repo_path="${!repo_var}"
    if [[ -d "$repo_path/.git" ]]; then
        echo "  ✓ ${repo_var}=${repo_path}"
        REPOS_AVAILABLE+=("${repo_var}=${repo_path}")
    else
        echo "  ✗ ${repo_var}=${repo_path} (not found or not a git repo)"
    fi
done

# ── Prepare workspace ─────────────────────────────────────────────────────────
echo ""
echo "── Preparing workspace ────────────────────────────────"

mkdir -p "$REPORTS_DIR"
echo "  Reports directory: $REPORTS_DIR"

# ── Build the prompt ──────────────────────────────────────────────────────────
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="${REPORTS_DIR}/verification-report-${JIRA_TICKET}-${TIMESTAMP}.md"

PROMPT="Run a full pre-release verification for Jira ticket ${JIRA_TICKET}.

## Inputs
- Jira Ticket: ${JIRA_TICKET}
"

if [[ -n "$TEST_ENV_URL" ]]; then
    PROMPT+="- Test Environment: ${TEST_ENV_URL}
"
fi

if [[ -n "$FIGMA_URL" ]]; then
    PROMPT+="- Figma URL: ${FIGMA_URL}
"
fi

PROMPT+="
## Available Repositories
"
for repo_info in "${REPOS_AVAILABLE[@]:-}"; do
    if [[ -n "$repo_info" ]]; then
        PROMPT+="- ${repo_info}
"
    fi
done

PROMPT+="
## Instructions

Follow the workflow in CLAUDE.md exactly:

Stage 0  → Load patterns/index.json and check for known patterns matching this feature
Stage 1  → Read Jira ticket via MCP, read Figma via MCP, generate test plan
Stage 2  → Verify test environment is accessible
Stage 3  → Set up test users (register → IPCF → admin approve) per rules/02-setup-protocol.md
Stage 4  → Visual verification against Figma specs per rules/03-visual-verification.md
Stage 5  → Business logic verification against Jira AC per rules/04-business-logic-verification.md
Stage 6  → Responsiveness check per rules/05-responsiveness-check.md
Stage 7  → Generate verification report to: ${REPORT_FILE}
Stage 8  → Feedback capture per rules/07-feedback-capture.md (non-negotiable)

Start by loading patterns/index.json, then fetch the Jira ticket."

# ── Run Claude Code ────────────────────────────────────────────────────────────
echo ""
echo "── Running TestPilotBot verification ──────────────────"
echo "  Ticket: $JIRA_TICKET"
[[ -n "$TEST_ENV_URL" ]] && echo "  Test env: $TEST_ENV_URL"
[[ -n "$FIGMA_URL" ]] && echo "  Figma: $FIGMA_URL"
echo "  Report will be saved to: $REPORT_FILE"
echo ""

cd "$PROJECT_DIR"

claude --dangerously-skip-permissions -p "$PROMPT"

# ── Post-run ──────────────────────────────────────────────────────────────────
echo ""
echo "── Verification complete ──────────────────────────────"

if [[ -f "$REPORT_FILE" ]]; then
    echo "  Report saved: $REPORT_FILE"
    echo ""
    echo "  To view: cat $REPORT_FILE"
else
    echo "  NOTE: Report not found at expected path."
    echo "  Check reports/ for the latest report."
    LATEST=$(ls -t "$REPORTS_DIR"/verification-report-*.md 2>/dev/null | head -1)
    if [[ -n "$LATEST" ]]; then
        echo "  Latest report: $LATEST"
    fi
fi

echo ""
echo "  Done."
