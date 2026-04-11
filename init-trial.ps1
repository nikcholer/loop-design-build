param(
    [string]$TrialName = ""
)

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
$SourceOuterLoopPlaybookPath = "docs\agent-loop\outer-loop-playbook.md"
$OuterLoopPlaybookFileName = "outer-loop-playbook.md"
$PlanningDocumentPath = "docs\planning.md"
$SkillInjectorRelativePath = "scripts\inject-skill.ps1"
$SkillsSectionHeading = "## Skills"
$SkillsSectionDescriptionLineOne = 'List optional harness skills to activate using one bullet per skill name from `~/.agents/skills/`.'
$SkillsSectionDescriptionLineTwo = "Leave this section empty if no extra skills are needed."
$SkillsSectionDescriptionLineThree = 'Example format: `- frontend-design`'
$SkillsSectionDescriptionLineFour = 'After updating this section, run the harness skill injector against the trial repo so the listed skills are copied into `.agents/skills/`.'
$PlanningTemplateContent = @'
# Target Architecture / Product Requirements

## Domain Overview

Describe the product or system being built, who it serves, and the main workflow the agent must support.

## Data Sources / Requirements

Paste or summarize the raw schema, API contracts, sample payloads, business rules, and any must-have behaviours that define the scope.

## Technical Constraints

List required environments, deployment constraints, coding standards beyond the default harness, performance limits, and any forbidden approaches.

## Preferred Stack

Specify the preferred languages, frameworks, libraries, databases, and tooling. If something is optional, say so explicitly.

__SKILLS_SECTION_HEADING__

__SKILLS_SECTION_DESCRIPTION_LINE_ONE__
__SKILLS_SECTION_DESCRIPTION_LINE_TWO__
__SKILLS_SECTION_DESCRIPTION_LINE_THREE__
__SKILLS_SECTION_DESCRIPTION_LINE_FOUR__

## Out of Scope

List features, integrations, migrations, or polish work that the agent should avoid during this run.
'@
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)
$CopyTemplatesMessage = "-> Copying templates to docs\templates..."
$SeedStateMessage = "-> Seeding active state documents..."
$RegisterSkillMessage = "-> Registering agent-loop.md skill..."
$CopyStandardsMessage = "-> Copying agent loop coding standards..."
$CopyOuterLoopPlaybookMessage = "-> Copying outer loop playbook..."
$InitializeGitMessage = "-> Initializing Git and committing scaffolding..."
$ScaffoldingHeaderPrefix = "`n🚀 Scaffolding new Agentic Trial Repo:"
$ScaffoldingLocationPrefix = "Location:"
$TargetExistsMessagePrefix = "Target directory already exists:"
$SuccessMessagePrefix = "✅ Trial successfully created at:"
$StartMessagePrefix = "To start: cd ../"
$StartMessageSuffix = " and update docs\planning.md!"
$SkillInjectorHintPrefix = "Optional: after listing skills in docs\planning.md, run"
$InitialCommitMessage = "chore: scaffold trial repo with agent loop skills and state templates"

$SourceRepo = $PWD.Path
$ParentDir = Split-Path -Path $SourceRepo -Parent
$SkillInjectorPath = Join-Path -Path $SourceRepo -ChildPath $SkillInjectorRelativePath

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

Write-Host "$ScaffoldingHeaderPrefix $TrialName"
Write-Host "$ScaffoldingLocationPrefix $TargetRepo"

$DocsDir = Join-Path -Path $TargetRepo -ChildPath $DocsDirectoryName
$StateDir = Join-Path -Path $DocsDir -ChildPath $StateDirectoryName
$TemplatesDir = Join-Path -Path $DocsDir -ChildPath $TemplatesDirectoryName
$AgentLoopDocsDir = Join-Path -Path $DocsDir -ChildPath $AgentLoopDirectoryName
$SkillsDir = Join-Path -Path $TargetRepo -ChildPath $SkillsDirectoryPath

New-Item -Path $StateDir -ItemType Directory -Force | Out-Null
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

$PlanningDoc = Join-Path -Path $TargetRepo -ChildPath $PlanningDocumentPath
$ResolvedPlanningTemplateContent = $PlanningTemplateContent.Replace("__SKILLS_SECTION_HEADING__", $SkillsSectionHeading)
$ResolvedPlanningTemplateContent = $ResolvedPlanningTemplateContent.Replace("__SKILLS_SECTION_DESCRIPTION_LINE_ONE__", $SkillsSectionDescriptionLineOne)
$ResolvedPlanningTemplateContent = $ResolvedPlanningTemplateContent.Replace("__SKILLS_SECTION_DESCRIPTION_LINE_TWO__", $SkillsSectionDescriptionLineTwo)
$ResolvedPlanningTemplateContent = $ResolvedPlanningTemplateContent.Replace("__SKILLS_SECTION_DESCRIPTION_LINE_THREE__", $SkillsSectionDescriptionLineThree)
$ResolvedPlanningTemplateContent = $ResolvedPlanningTemplateContent.Replace("__SKILLS_SECTION_DESCRIPTION_LINE_FOUR__", $SkillsSectionDescriptionLineFour)
[System.IO.File]::WriteAllText($PlanningDoc, $ResolvedPlanningTemplateContent, $Utf8NoBomEncoding)

Write-Host $InitializeGitMessage
Push-Location -Path $TargetRepo

git init | Out-Null
git add .
git commit -m $InitialCommitMessage | Out-Null

Pop-Location

Write-Host "$SuccessMessagePrefix $TargetRepo"
Write-Host "$StartMessagePrefix$TrialName$StartMessageSuffix"
Write-Host ('{0} "{1}" -TargetRepoPath "{2}"' -f $SkillInjectorHintPrefix, $SkillInjectorPath, $TargetRepo)
Write-Host ""
