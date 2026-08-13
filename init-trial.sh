#!/usr/bin/env bash
set -e

TrialName=""
TargetPath=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--target) TargetPath="$2"; shift ;;
        *) TrialName="$1" ;;
    esac
    shift
done

SourceRepo="$(pwd)"

if [ -z "$TargetPath" ]; then
    if [ -z "$TrialName" ]; then
        timestamp=$(date +"%Y%m%d%H%M%S")
        TrialName="Trial-$timestamp"
    fi

    TargetRepo="$(cd ../ && pwd)/$TrialName"

    if [ -d "$TargetRepo" ]; then
        echo "Target directory already exists: $TargetRepo"
        exit 1
    fi
else
    TargetRepo="$(cd "$TargetPath" && pwd)"
    echo "-> Injecting into existing repository at: $TargetRepo"
    
    ConflictFiles=("docs/planning.md" ".agents/skills/agent-loop.md" "docs/agent-loop/outer-loop-playbook.md")
    for file in "${ConflictFiles[@]}"; do
        if [ -f "$TargetRepo/$file" ]; then
            echo "Conflict detected: The file '$file' already exists in the target repository. Scaffolding aborted to prevent overwriting."
            exit 1
        fi
    done
fi

echo ""
echo "===================================================="
echo " 🚀 SCAFFOLDING NEW AGENTIC TRIAL"
echo "===================================================="
echo "Location: $TargetRepo"

DocsDir="$TargetRepo/docs"
StateDir="$DocsDir/state"
StateArchiveDir="$StateDir/archive"
TemplatesDir="$DocsDir/templates"
AgentLoopDocsDir="$DocsDir/agent-loop"
SkillsDir="$TargetRepo/.agents/skills"

mkdir -p "$StateArchiveDir"
mkdir -p "$TemplatesDir"
mkdir -p "$AgentLoopDocsDir"
mkdir -p "$SkillsDir"

echo "-> Copying templates to docs/templates..."
cp -R docs/agent-loop/templates/* "$TemplatesDir/"

echo "-> Seeding active state documents..."
cp "$TemplatesDir/handover.md" "$StateDir/"
cp "$TemplatesDir/backlog.md" "$StateDir/"
cp "$TemplatesDir/progress.md" "$StateDir/"

echo "-> Registering agent-loop.md skill..."
cp docs/agent-loop/skill.md "$SkillsDir/agent-loop.md"
cp docs/agent-loop/skill.md "$AgentLoopDocsDir/skill.md"

echo "-> Copying agent loop coding standards..."
cp docs/agent-loop/standards.md "$AgentLoopDocsDir/standards.md"
if [ -f docs/agent-loop/standards.sample.md ]; then
    cp docs/agent-loop/standards.sample.md "$AgentLoopDocsDir/standards.sample.md"
fi

echo "-> Copying outer loop playbook..."
cp docs/agent-loop/outer-loop-playbook.md "$AgentLoopDocsDir/outer-loop-playbook.md"

echo "-> Copying operator scripts..."
TargetScriptsDir="$TargetRepo/scripts"
mkdir -p "$TargetScriptsDir"
for scriptName in check-health.ps1 check-health.sh run-loop.ps1 run-loop.sh archive-backlog.ps1 inject-skill.ps1; do
    if [ -f "scripts/$scriptName" ]; then
        cp "scripts/$scriptName" "$TargetScriptsDir/$scriptName"
    fi
done

echo "-> Seeding planning document..."
cp docs/agent-loop/templates/planning.md "$DocsDir/planning.md"

cd "$TargetRepo"

if [ ! -d ".git" ]; then
    echo "-> Initializing Git and committing scaffolding..."
    git init >/dev/null 2>&1
    git add .
    git commit -m "chore: scaffold trial repo with agent loop skills and state templates" >/dev/null 2>&1
else
    echo "-> Existing Git repository detected. Staging agent harness files..."
    git add docs/ .agents/ scripts/
    git commit -m "chore: integrate agent loop harness" >/dev/null 2>&1
fi

echo -e "\033[0;32m✅ SUCCESS: Agentic Loop Harness scaffolded successfully.\033[0m"
echo "  Location: $TargetRepo"
echo ""
echo -e "\033[0;36m[NEXT STEPS]\033[0m"
if [ -z "$TargetPath" ]; then
    echo "  1. cd ../$TrialName"
else
    echo "  1. cd \"$TargetRepo\""
fi
echo "  2. Populate docs/planning.md and docs/state/backlog.md"
echo "  3. Run: git status && bash scripts/check-health.sh"
echo "  4. grok -p \"Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state.\" --always-approve --max-turns 15"
echo ""
