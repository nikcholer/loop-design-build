param(
    [string]$TrialName = ""
)

# Ensure script halts on errors
$ErrorActionPreference = "Stop"

$DocsDirectoryName = "docs"
$StateDirectoryName = "state"
$TemplatesDirectoryName = "templates"
$AgentLoopDirectoryName = "agent-loop"
$SkillsDirectoryPath = ".agents\skills"
$SourceTemplatesPath = "docs\agent-loop\templates\*"
$HandoverFileName = "handover.md"
$BacklogFileName = "backlog.md"
$ProgressFileName = "progress.md"
$SourceSkillPath = "docs\agent-loop\skill.md"
$SkillFileName = "agent-loop.md"
$SourceStandardsPath = "docs\agent-loop\standards.md"
$StandardsFileName = "standards.md"
$PlanningDocumentPath = "docs\planning.md"
$CopyTemplatesMessage = "-> Copying templates to docs\templates..."
$SeedStateMessage = "-> Seeding active state documents..."
$RegisterSkillMessage = "-> Registering agent-loop.md skill..."
$CopyStandardsMessage = "-> Copying agent loop coding standards..."

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
$DocsDir = Join-Path -Path $TargetRepo -ChildPath $DocsDirectoryName
$StateDir = Join-Path -Path $DocsDir -ChildPath $StateDirectoryName
$TemplatesDir = Join-Path -Path $DocsDir -ChildPath $TemplatesDirectoryName
$AgentLoopDocsDir = Join-Path -Path $DocsDir -ChildPath $AgentLoopDirectoryName
$SkillsDir = Join-Path -Path $TargetRepo -ChildPath $SkillsDirectoryPath

New-Item -Path $StateDir -ItemType Directory -Force | Out-Null
New-Item -Path $TemplatesDir -ItemType Directory -Force | Out-Null
New-Item -Path $AgentLoopDocsDir -ItemType Directory -Force | Out-Null
New-Item -Path $SkillsDir -ItemType Directory -Force | Out-Null

# Copy templates to docs\templates directory
$SourceTemplates = Join-Path -Path $SourceRepo -ChildPath $SourceTemplatesPath
Write-Host $CopyTemplatesMessage
Copy-Item -Path $SourceTemplates -Destination $TemplatesDir -Recurse -Force

# Seed the initial ACTIVE state documents (excluding TBDs to prevent false blockers)
Write-Host $SeedStateMessage
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath $HandoverFileName) -Destination $StateDir -Force
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath $BacklogFileName) -Destination $StateDir -Force
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath $ProgressFileName) -Destination $StateDir -Force

# Copy skill to antigravity skills folder
$SourceSkill = Join-Path -Path $SourceRepo -ChildPath $SourceSkillPath
$DestSkill = Join-Path -Path $SkillsDir -ChildPath $SkillFileName
Write-Host $RegisterSkillMessage
Copy-Item -Path $SourceSkill -Destination $DestSkill -Force

# Copy coding standards required by the agent loop
$SourceStandards = Join-Path -Path $SourceRepo -ChildPath $SourceStandardsPath
$DestStandards = Join-Path -Path $AgentLoopDocsDir -ChildPath $StandardsFileName
Write-Host $CopyStandardsMessage
Copy-Item -Path $SourceStandards -Destination $DestStandards -Force

# Create a blank planning document for the user to paste their schema
$PlanningDoc = Join-Path -Path $TargetRepo -ChildPath $PlanningDocumentPath
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
