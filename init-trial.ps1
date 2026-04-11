param(
    [string]$TrialName = ""
)

# Ensure script halts on errors
$ErrorActionPreference = "Stop"

$SourceRepo = $PWD.Path
$ParentDir = Split-Path -Path $SourceRepo -Parent

# Generate default name if none is provided
if ([string]::IsNullOrWhiteSpace($TrialName)) {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $TrialName = "Trial-$timestamp"
}

$TargetRepo = Join-Path -Path $ParentDir -ChildPath $TrialName

if (Test-Path $TargetRepo) {
    Write-Error "Target directory already exists: $TargetRepo"
    exit 1
}

Write-Host "`n🚀 Scaffolding new Agentic Trial Repo: $TrialName"
Write-Host "Location: $TargetRepo"

# Build core directory structure
$DocsDir = Join-Path -Path $TargetRepo -ChildPath "docs"
$StateDir = Join-Path -Path $DocsDir -ChildPath "state"
$TemplatesDir = Join-Path -Path $DocsDir -ChildPath "templates"
$SkillsDir = Join-Path -Path $TargetRepo -ChildPath ".agents\skills"

New-Item -Path $StateDir -ItemType Directory -Force | Out-Null
New-Item -Path $TemplatesDir -ItemType Directory -Force | Out-Null
New-Item -Path $SkillsDir -ItemType Directory -Force | Out-Null

# Copy templates to docs\templates directory
$SourceTemplates = Join-Path -Path $SourceRepo -ChildPath "docs\agent-loop\templates\*"
Write-Host "-> Copying templates to docs\templates..."
Copy-Item -Path $SourceTemplates -Destination $TemplatesDir -Recurse -Force

# Seed the initial ACTIVE state documents (excluding TBDs to prevent false blockers)
Write-Host "-> Seeding active state documents..."
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath "handover.md") -Destination $StateDir -Force
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath "backlog.md") -Destination $StateDir -Force
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath "progress.md") -Destination $StateDir -Force

# Copy skill to antigravity skills folder
$SourceSkill = Join-Path -Path $SourceRepo -ChildPath "docs\agent-loop\skill.md"
$DestSkill = Join-Path -Path $SkillsDir -ChildPath "agent-loop.md"
Write-Host "-> Registering agent-loop.md skill..."
Copy-Item -Path $SourceSkill -Destination $DestSkill -Force

# Create a blank planning document for the user to paste their schema
$PlanningDoc = Join-Path -Path $TargetRepo -ChildPath "docs\planning.md"
"# Target Architecture / Product Requirements`n`n> Paste your raw schema or requirements data here to constrain the agent." | Out-File -FilePath $PlanningDoc

# Initialize git and perform the first commit
Write-Host "-> Initializing Git and committing scaffolding..."
Push-Location -Path $TargetRepo

git init | Out-Null
git add .
git commit -m "chore: scaffold trial repo with agent loop skills and state templates" | Out-Null

Pop-Location

Write-Host "✅ Trial successfully created at: $TargetRepo"
Write-Host "To start: cd ../$TrialName and update docs\planning.md!"
Write-Host ""
