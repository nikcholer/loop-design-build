#!/usr/bin/env bash
set -euo pipefail

Provider="grok"
MaxRuns=3
Command=""
RepositoryRoot="$(cd "$(dirname "$0")/.." && pwd)"
WaitForResponse=0

LoopPrompt='Read .agents/skills/agent-loop.md and execute the next run strictly from the repository'\''s local markdown state.'

while [[ $# -gt 0 ]]; do
    case "$1" in
        --provider) Provider="$2"; shift 2 ;;
        --max-runs) MaxRuns="$2"; shift 2 ;;
        --command) Command="$2"; shift 2 ;;
        --cwd) RepositoryRoot="$(cd "$2" && pwd)"; shift 2 ;;
        --wait-for-response) WaitForResponse=1; shift ;;
        -h|--help)
            echo "Usage: run-loop.sh [--provider grok|claude|gemini|codex|aider|opencode] [--max-runs N] [--command \"...\"] [--wait-for-response]"
            exit 0
            ;;
        *)
            echo "Unknown flag: $1" >&2
            exit 1
            ;;
    esac
done

if ! [[ "$MaxRuns" =~ ^[1-9][0-9]*$ ]]; then
    echo "--max-runs must be a positive integer." >&2
    exit 1
fi

case "$Provider" in
    grok) DefaultCommand="grok -p \"$LoopPrompt\" --always-approve --max-turns 15" ;;
    claude) DefaultCommand="claude -p \"$LoopPrompt\" --dangerously-skip-permissions --max-turns 15" ;;
    gemini) DefaultCommand="gemini -m gemini-2.5-pro --approval-mode yolo -p \"$LoopPrompt\"" ;;
    codex) DefaultCommand="codex exec --dangerously-bypass-approvals-and-sandbox \"$LoopPrompt\"" ;;
    aider) DefaultCommand="aider -m \"$LoopPrompt\" --yes --no-gitignore" ;;
    opencode) DefaultCommand="opencode run --dangerously-skip-permissions --log-level WARN \"$LoopPrompt\"" ;;
    *)
        echo "Unknown provider: $Provider" >&2
        exit 1
        ;;
esac

ResolvedCommand="${Command:-$DefaultCommand}"
TbdPath="$RepositoryRoot/docs/state/tbd.md"
TbdResponsePath="$RepositoryRoot/docs/state/tbd-response.md"

tbd_blocks_run() {
    [[ -f "$TbdPath" && ! -f "$TbdResponsePath" ]]
}

wait_for_response() {
    echo "Waiting for docs/state/tbd-response.md ... (Ctrl+C to stop)"
    while [[ ! -f "$TbdResponsePath" ]]; do
        sleep 5
    done
}

if ! tbd_blocks_run; then
    bash "$(dirname "$0")/check-health.sh" "$RepositoryRoot"
fi

for ((run=1; run<=MaxRuns; run++)); do
    if tbd_blocks_run; then
        echo "Stop: unresolved TBD at docs/state/tbd.md (before run $run)."
        if [[ "$WaitForResponse" -eq 1 ]]; then
            wait_for_response
        else
            exit 0
        fi
    fi

    echo ""
    echo "=== Loop run $run of $MaxRuns ==="
    (
        cd "$RepositoryRoot"
        eval "$ResolvedCommand"
    )

    if tbd_blocks_run; then
        echo "Stop: agent published docs/state/tbd.md. Resolve it before the next run."
        if [[ "$WaitForResponse" -eq 1 && "$run" -lt "$MaxRuns" ]]; then
            wait_for_response
            continue
        fi
        exit 0
    fi
done

echo "Completed $MaxRuns run(s) without an unresolved TBD."
