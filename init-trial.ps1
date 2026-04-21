param(
    [string]$TrialName = "",
    [string]$TargetRepoPath = ""
)

$ErrorActionPreference = "Stop"

$DocsDirectoryName = "docs"
$StateDirectoryName = "state"
$TemplatesDirectoryName = "templates"
$AgentLoopDirectoryName = "agent-loop"
$SkillsDirectoryPath = ".agents\skills"
$ArchiveDirectoryName = "archive"
$SourceTemplatesPath = "docs\agent-loop\templates\*"
$HandoverFileName = "handover.md"
$BacklogFileName = "backlog.md"
$ProgressFileName = "progress.md"
$PlanningFileName = "planning.md"
$SourceSkillPath = "docs\agent-loop\skill.md"
$SkillFileName = "agent-loop.md"
$SourceStandardsPath = "docs\agent-loop\standards.md"
$StandardsFileName = "standards.md"
$SourceOuterLoopPlaybookPath = "docs\agent-loop\outer-loop-playbook.md"
$OuterLoopPlaybookFileName = "outer-loop-playbook.md"
$SkillInjectorRelativePath = "scripts\inject-skill.ps1"
$SourcePlanningTemplatePath = "docs\agent-loop\templates\planning.md"
$CopyTemplatesMessage = "-> Copying templates to docs\templates..."
$SeedStateMessage = "-> Seeding active state documents..."
$SeedPlanningMessage = "-> Seeding planning document..."
$RegisterSkillMessage = "-> Registering agent-loop.md skill..."
$CopyStandardsMessage = "-> Copying agent loop coding standards..."
$CopyOuterLoopPlaybookMessage = "-> Copying outer loop playbook..."
$InitializeGitMessage = "-> Initializing Git and committing scaffolding..."
$ScaffoldingHeaderPrefix = "`n🚀 Scaffolding new Agentic Trial Repo:"
$ScaffoldingLocationPrefix = "Location:"
$TargetExistsMessagePrefix = "Target directory already exists:"
$SuccessMessagePrefix = "✅ Trial successfully created at:"
$StartMessagePrefix = "To begin: cd ../"
$StartMessageSuffix = " and update docs\planning.md"
$SkillInjectorHintPrefix = "Then run (optional):"
$InitialCommitMessage = "chore: scaffold trial repo with agent loop skills and state templates"

$SourceRepo = $PWD.Path
$ParentDir = Split-Path -Path $SourceRepo -Parent
$SkillInjectorPath = Join-Path -Path $SourceRepo -ChildPath $SkillInjectorRelativePath

if ([string]::IsNullOrWhiteSpace($TargetRepoPath)) {
    if ([string]::IsNullOrWhiteSpace($TrialName)) {
        $TimestampFormat = "yyyyMMddHHmmss"
        $timestamp = Get-Date -Format $TimestampFormat
        $TrialName = "Trial-$timestamp"
    }

    $TargetRepo = Join-Path -Path $ParentDir -ChildPath $TrialName

    if (Test-Path -LiteralPath $TargetRepo) {
        Write-Error "$TargetExistsMessagePrefix $TargetRepo"
        exit 1
    }
} else {
    $TargetRepo = (Resolve-Path -Path $TargetRepoPath -ErrorAction Stop).Path
    Write-Host "-> Injecting into existing repository at: $TargetRepo"

    $ConflictFiles = @(
        "docs\planning.md",
        ".agents\skills\agent-loop.md",
        "docs\agent-loop\outer-loop-playbook.md"
    )
    foreach ($file in $ConflictFiles) {
        if (Test-Path (Join-Path $TargetRepo $file)) {
            Write-Error "Conflict detected: The file '$file' already exists in the target repository. Scaffolding aborted to prevent overwriting."
            exit 1
        }
    }
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " 🚀 SCAFFOLDING NEW AGENTIC TRIAL" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "$ScaffoldingLocationPrefix $TargetRepo"

$DocsDir = Join-Path -Path $TargetRepo -ChildPath $DocsDirectoryName
$StateDir = Join-Path -Path $DocsDir -ChildPath $StateDirectoryName
$StateArchiveDir = Join-Path -Path $StateDir -ChildPath $ArchiveDirectoryName
$TemplatesDir = Join-Path -Path $DocsDir -ChildPath $TemplatesDirectoryName
$AgentLoopDocsDir = Join-Path -Path $DocsDir -ChildPath $AgentLoopDirectoryName
$SkillsDir = Join-Path -Path $TargetRepo -ChildPath $SkillsDirectoryPath

New-Item -Path $StateDir -ItemType Directory -Force | Out-Null
New-Item -Path $StateArchiveDir -ItemType Directory -Force | Out-Null
New-Item -Path $TemplatesDir -ItemType Directory -Force | Out-Null
New-Item -Path $AgentLoopDocsDir -ItemType Directory -Force | Out-Null
New-Item -Path $SkillsDir -ItemType Directory -Force | Out-Null

$SourceTemplates = Join-Path -Path $SourceRepo -ChildPath $SourceTemplatesPath
Write-Host $CopyTemplatesMessage
Copy-Item -Path $SourceTemplates -Destination $TemplatesDir -Recurse -Force

Write-Host $SeedStateMessage
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath $HandoverFileName) -Destination $StateDir -Force
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath $BacklogFileName) -Destination $StateDir -Force
Copy-Item -Path (Join-Path -Path $TemplatesDir -ChildPath $ProgressFileName) -Destination $StateDir -Force

$SourceSkill = Join-Path -Path $SourceRepo -ChildPath $SourceSkillPath
$DestSkill = Join-Path -Path $SkillsDir -ChildPath $SkillFileName
Write-Host $RegisterSkillMessage
Copy-Item -Path $SourceSkill -Destination $DestSkill -Force

$SourceStandards = Join-Path -Path $SourceRepo -ChildPath $SourceStandardsPath
$DestStandards = Join-Path -Path $AgentLoopDocsDir -ChildPath $StandardsFileName
Write-Host $CopyStandardsMessage
Copy-Item -Path $SourceStandards -Destination $DestStandards -Force

$SourceOuterLoopPlaybook = Join-Path -Path $SourceRepo -ChildPath $SourceOuterLoopPlaybookPath
$DestOuterLoopPlaybook = Join-Path -Path $AgentLoopDocsDir -ChildPath $OuterLoopPlaybookFileName
Write-Host $CopyOuterLoopPlaybookMessage
Copy-Item -Path $SourceOuterLoopPlaybook -Destination $DestOuterLoopPlaybook -Force

$SourcePlanningTemplate = Join-Path -Path $SourceRepo -ChildPath $SourcePlanningTemplatePath
$PlanningDoc = Join-Path -Path $DocsDir -ChildPath $PlanningFileName
Write-Host $SeedPlanningMessage
Copy-Item -Path $SourcePlanningTemplate -Destination $PlanningDoc -Force

Push-Location -Path $TargetRepo

if (-not (Test-Path ".git")) {
    Write-Host $InitializeGitMessage
    git init | Out-Null
    git add .
    git commit -m $InitialCommitMessage | Out-Null
} else {
    Write-Host "-> Existing Git repository detected. Staging agent harness files..."
    git add docs\ .agents\
    git commit -m "chore: integrate agent loop harness" | Out-Null
}

Pop-Location

Write-Host "`n$SuccessMessagePrefix" -ForegroundColor Green
Write-Host "  $TargetRepo"
Write-Host "`n$StartMessagePrefix$TrialName$StartMessageSuffix" -ForegroundColor Yellow
Write-Host "`n$SkillInjectorHintPrefix" -ForegroundColor Gray
Write-Host "  powershell.exe -File ""$SkillInjectorPath"" -TargetRepoPath ""$TargetRepo""" -ForegroundColor Gray
Write-Host ""
