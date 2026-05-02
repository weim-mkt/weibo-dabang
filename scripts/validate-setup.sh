#!/usr/bin/env bash
# =============================================================================
# validate-setup.sh — Verify dependencies for the Weibo Dabang JMR R&R workflow
#
# Run this after copying the workflow into the project root or after pulling
# updates. Exits 0 if all required tools are found; non-zero otherwise.
# Beamer/MacTeX checks were dropped because the paper lives in the Overleaf
# submodule and compiles there, not locally.
# =============================================================================

set -uo pipefail

# ANSI colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass=0
warn=0
fail=0

echo ""
echo -e "${BOLD}Validating Weibo Dabang JMR R&R workflow setup...${RESET}"
echo ""

check_required() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} $name found: $("$cmd" --version 2>&1 | head -n1)"
        pass=$((pass + 1))
    else
        echo -e "  ${RED}✗${RESET} $name NOT FOUND — install: ${install_url}"
        fail=$((fail + 1))
    fi
}

check_optional() {
    local name="$1"
    local cmd="$2"
    local install_url="$3"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${RESET} $name found: $("$cmd" --version 2>&1 | head -n1)"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $name not found (optional) — install: ${install_url}"
        warn=$((warn + 1))
    fi
}

echo -e "${BOLD}Required tools:${RESET}"
check_required "Claude Code"  "claude"   "https://claude.ai/install"
check_required "R"            "R"        "https://www.r-project.org/"
check_required "git"          "git"      "https://git-scm.com/downloads"
check_required "Python 3"     "python3"  "https://python.org (used by hooks + scripts)"
echo ""

echo -e "${BOLD}Recommended tools:${RESET}"
check_optional "Quarto"       "quarto"   "https://quarto.org/docs/get-started/  (slides for internal updates / talks)"
check_optional "GitHub CLI"   "gh"       "https://cli.github.com/"
check_optional "Stata (parity checks)" "stata" "https://www.stata.com — only needed when running coauthor's .do files side-by-side with the R port"
check_optional "jq"           "jq"       "brew install jq (Linux: apt install jq) — used by the notify hook"
echo ""

echo -e "${BOLD}Git configuration:${RESET}"
if command -v git >/dev/null 2>&1; then
    git_name=$(git config user.name 2>/dev/null || true)
    git_email=$(git config user.email 2>/dev/null || true)
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        echo -e "  ${GREEN}✓${RESET} git user: $git_name <$git_email>"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} git user.name / user.email not set"
        echo -e "    Run: git config --global user.name \"Your Name\""
        echo -e "    Run: git config --global user.email \"you@example.com\""
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} skipped — install git first (see required tools above)"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Submodule status:${RESET}"
if [ -d "overleaf-weibo-dabang/.git" ] || [ -f "overleaf-weibo-dabang/.git" ]; then
    submodule_status=$(git submodule status overleaf-weibo-dabang 2>/dev/null | head -n1)
    if [ -n "$submodule_status" ]; then
        echo -e "  ${GREEN}✓${RESET} overleaf-weibo-dabang submodule initialized: $submodule_status"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} overleaf-weibo-dabang submodule directory exists but git submodule status is empty"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} overleaf-weibo-dabang submodule not initialized — run: git submodule update --init"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Data symlink:${RESET}"
if [ -L "data/raw" ] && [ -e "data/raw" ]; then
    target=$(readlink data/raw)
    echo -e "  ${GREEN}✓${RESET} data/raw -> $target (resolves)"
    pass=$((pass + 1))
elif [ -L "data/raw" ]; then
    echo -e "  ${RED}✗${RESET} data/raw symlink exists but target is missing — re-link to your local copy of the dataset"
    fail=$((fail + 1))
else
    echo -e "  ${YELLOW}⚠${RESET} data/raw symlink not present — link to your local Dropbox copy of 'Sina Dabang/data'"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Claude Code hooks:${RESET}"
hook_dir="$(dirname "$0")/../.claude/hooks"
if [ -d "$hook_dir" ]; then
    non_exec=$(find "$hook_dir" -maxdepth 1 \( -name "*.py" -o -name "*.sh" \) ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
    if [ "$non_exec" -eq 0 ]; then
        echo -e "  ${GREEN}✓${RESET} All hook scripts are executable"
        pass=$((pass + 1))
    else
        echo -e "  ${YELLOW}⚠${RESET} $non_exec hook script(s) not executable"
        echo -e "    Fix: chmod +x .claude/hooks/*.py .claude/hooks/*.sh"
        warn=$((warn + 1))
    fi
else
    echo -e "  ${YELLOW}⚠${RESET} .claude/hooks/ directory not found (are you in the project root?)"
    warn=$((warn + 1))
fi
echo ""

echo -e "${BOLD}Summary:${RESET} ${GREEN}${pass} passed${RESET}, ${YELLOW}${warn} warnings${RESET}, ${RED}${fail} failed${RESET}"
echo ""

has_claude="false";  command -v claude  >/dev/null 2>&1 && has_claude="true"
has_r="false";       command -v R       >/dev/null 2>&1 && has_r="true"
has_quarto="false";  command -v quarto  >/dev/null 2>&1 && has_quarto="true"

if [ "$fail" -gt 0 ]; then
    echo -e "${RED}Some required tools are missing.${RESET}"
    echo ""
    echo -e "${BOLD}What you CAN do right now:${RESET}"
    if [ "$has_claude" = "true" ]; then
        echo "  - Open Claude Code: claude"
        echo ""
        echo "  ${BOLD}Inside Claude Code${RESET} (slash-commands):"
        if [ "$has_r" = "true" ]; then
            echo "    /data-analysis             # scaffold an R analysis pipeline"
        fi
        if [ "$has_quarto" = "true" ]; then
            echo "    /deploy <DeckName>         # render a Quarto deck"
        fi
        echo "    /respond-to-referees       # draft R&R responses (paper in overleaf-weibo-dabang/)"
    else
        echo "  - Install Claude Code first: https://claude.ai/install"
    fi
    echo ""
    echo -e "${BOLD}Next:${RESET} install the missing required tool(s) listed above, then re-run this script."
    exit 1
fi

echo -e "${GREEN}Setup looks good!${RESET} Next steps:"
echo "  1. Open Claude Code in this directory:  claude"
echo "  2. Scaffold the R replication:           /data-analysis"
echo "  3. Browse the round-1 review letter:     overleaf-weibo-dabang/response_letter_JMR_first_round.tex"
echo ""
exit 0
