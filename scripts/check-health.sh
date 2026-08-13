#!/usr/bin/env bash
set -euo pipefail

RepositoryRoot="$(cd "$(dirname "$0")/.." && pwd)"
VerificationCommand=()

if [[ $# -gt 0 && -d "${1:-}/.git" ]]; then
    RepositoryRoot="$(cd "$1" && pwd)"
    shift
    if [[ "${1:-}" == "--" ]]; then
        shift
    fi
    VerificationCommand=("$@")
elif [[ "${1:-}" == "--" ]]; then
    shift
    VerificationCommand=("$@")
elif [[ $# -gt 0 ]]; then
    VerificationCommand=("$@")
fi

TbdRelativePath="docs/state/tbd.md"
TbdResponseRelativePath="docs/state/tbd-response.md"
BacklogRelativePath="docs/state/backlog.md"

issues=()
notes=()

if ! git -C "$RepositoryRoot" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository."
    exit 1
fi

if [[ -f "$RepositoryRoot/$TbdRelativePath" && ! -f "$RepositoryRoot/$TbdResponseRelativePath" ]]; then
    issues+=("Unresolved blocker: docs/state/tbd.md exists without docs/state/tbd-response.md.")
fi

status_output="$(git -C "$RepositoryRoot" status --porcelain)"
if [[ -n "$status_output" ]]; then
    issues+=("Uncommitted changes detected in the repository.")
fi

backlog_path="$RepositoryRoot/$BacklogRelativePath"
if [[ -f "$backlog_path" ]]; then
    checklist_count=0
    open_count=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[[:space:]]*[-*][[:space:]]+\[([xX\ ])\] ]]; then
            checklist_count=$((checklist_count + 1))
            if [[ "${BASH_REMATCH[1]}" == " " ]]; then
                open_count=$((open_count + 1))
            fi
        fi
    done < "$backlog_path"
    if [[ "$checklist_count" -gt 0 && "$open_count" -eq 0 ]]; then
        notes+=("All backlog items are complete. Consider tagging a milestone before adding new work.")
    fi
fi

if [[ ${#VerificationCommand[@]} -gt 0 ]]; then
    echo "Running baseline verification command: ${VerificationCommand[*]}"
    (
        cd "$RepositoryRoot"
        "${VerificationCommand[@]}"
    )
    notes+=("Baseline verification command passed.")
else
    notes+=("Skipped baseline verification; pass a command after the repo path to run project-specific checks.")
fi

for note in "${notes[@]}"; do
    echo "$note"
done

if [[ ${#issues[@]} -gt 0 ]]; then
    for issue in "${issues[@]}"; do
        echo "$issue"
    done
    echo "Fix before running"
    exit 1
fi

echo "Ready"
