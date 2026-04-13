#!/usr/bin/env bash
set -e

TrialName="$1"
SourceRepo="$(pwd)"

if [ -z "$TrialName" ]; then
    timestamp=$(date +"%Y%m%d%H%M%S")
    TrialName="Trial-$timestamp"
fi

TargetRepo="$(cd ../ && pwd)/$TrialName"

if [ -d "$TargetRepo" ]; then
    echo "Target directory already exists: $TargetRepo"
    exit 1
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

echo "-> Initializing Git and committing scaffolding..."
cd "$TargetRepo"
git init >/dev/null 2>&1
git add .
git commit -m "chore: scaffold trial repo with agent loop skills and state templates" >/dev/null 2>&1

echo ""
echo "✅ Trial successfully created at:"
echo "  $TargetRepo"
echo ""
echo -e "\033[33mTo begin: cd ../$TrialName and update docs/planning.md\033[0m"
echo ""
