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
$StateDir = Join-Path -Path $TargetRepo -ChildPath "docs\state"
$SkillsDir = Join-Path -Path $TargetRepo -ChildPath ".agents\skills"

New-Item -Path $StateDir -ItemType Directory -Force | Out-Null
New-Item -Path $SkillsDir -ItemType Directory -Force | Out-Null

# Copy templates to state directory
$SourceTemplates = Join-Path -Path $SourceRepo -ChildPath "docs\agent-loop\templates\*"
Write-Host "-> Copying state templates..."
Copy-Item -Path $SourceTemplates -Destination $StateDir -Recurse -Force

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
