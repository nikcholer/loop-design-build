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

echo "-> Copying agent loop coding standards..."
cp docs/agent-loop/standards.md "$AgentLoopDocsDir/standards.md"

echo "-> Copying outer loop playbook..."
cp docs/agent-loop/outer-loop-playbook.md "$AgentLoopDocsDir/outer-loop-playbook.md"

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
    git add docs/ .agents/
    git commit -m "chore: integrate agent loop harness" >/dev/null 2>&1
fi

echo -e "\033[0;32m✅ SUCCESS: Agentic Loop Harness scaffolded successfully.\033[0m"
echo "  Location: $TargetRepo"
echo ""
echo -e "\033[0;36m[NEXT STEPS]\033[0m"
echo "  1. cd ../$TrialName"
echo "  2. Populate docs/planning.md and docs/state/backlog.md"
echo "  3. Run your agent (e.g., aider --message 'Read docs/agent-loop/skill.md...')"
echo ""
