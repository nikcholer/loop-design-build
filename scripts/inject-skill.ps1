param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepoPath,

    [string]$PlanningDocumentRelativePath = "docs\planning.md",

    [string]$DestinationSkillsRelativePath = ".agents\skills",

    [string]$SourceSkillsRootPath = ""
)

$ErrorActionPreference = "Stop"

$SkillsSectionHeading = "## Skills"
$SectionHeadingPrefix = "## "
$SkillBulletPattern = '^\s*-\s+`?([A-Za-z0-9._-]+)`?\s*$'
$DefaultSourceSkillsRelativePath = ".agents\skills"
$MarkdownFileExtension = ".md"
$NoSkillsMessage = "No optional skills were listed in the planning document."
$CopyingSkillMessagePrefix = "-> Copying skill"
$CopiedSkillsMessagePrefix = "Copied skills:"
$PlanningDocumentMissingMessagePrefix = "Planning document not found:"
$SkillsSectionMissingMessagePrefix = "Skills section not found in planning document:"
$SourceSkillMissingMessagePrefix = "Skill not found in source skills directory:"

function Get-SkillNamesFromPlanningDocument {
    param(
        [string[]]$PlanningDocumentLines,
        [string]$ResolvedPlanningDocumentPath
    )

    $sectionStartIndex = -1

    for ($lineIndex = 0; $lineIndex -lt $PlanningDocumentLines.Count; $lineIndex++) {
        if ($PlanningDocumentLines[$lineIndex].Trim() -eq $SkillsSectionHeading) {
            $sectionStartIndex = $lineIndex
            break
        }
    }

    if ($sectionStartIndex -lt 0) {
        throw "$SkillsSectionMissingMessagePrefix $ResolvedPlanningDocumentPath"
    }

    $skillNames = New-Object System.Collections.Generic.List[string]

    for ($lineIndex = $sectionStartIndex + 1; $lineIndex -lt $PlanningDocumentLines.Count; $lineIndex++) {
        $currentLine = $PlanningDocumentLines[$lineIndex]
        $trimmedLine = $currentLine.Trim()

        if ($trimmedLine.StartsWith($SectionHeadingPrefix)) {
            break
        }

        if ($trimmedLine -match $SkillBulletPattern) {
            $skillName = $Matches[1]

            if (-not $skillNames.Contains($skillName)) {
                $skillNames.Add($skillName)
            }
        }
    }

    return $skillNames
}

function Get-SourceSkillItem {
    param(
        [string]$SkillName,
        [string]$ResolvedSourceSkillsRootPath
    )

    $sourceSkillPath = Join-Path -Path $ResolvedSourceSkillsRootPath -ChildPath $SkillName

    if (Test-Path -LiteralPath $sourceSkillPath) {
        return Get-Item -LiteralPath $sourceSkillPath
    }

    $sourceSkillMarkdownPath = Join-Path -Path $ResolvedSourceSkillsRootPath -ChildPath ($SkillName + $MarkdownFileExtension)

    if (Test-Path -LiteralPath $sourceSkillMarkdownPath) {
        return Get-Item -LiteralPath $sourceSkillMarkdownPath
    }

    throw "$SourceSkillMissingMessagePrefix $SkillName"
}

$ResolvedSourceSkillsRootPath = $SourceSkillsRootPath

if ([string]::IsNullOrWhiteSpace($ResolvedSourceSkillsRootPath)) {
    $ResolvedSourceSkillsRootPath = Join-Path -Path $HOME -ChildPath $DefaultSourceSkillsRelativePath
}

$ResolvedTargetRepoPath = (Resolve-Path -Path $TargetRepoPath).Path
$PlanningDocumentPath = Join-Path -Path $ResolvedTargetRepoPath -ChildPath $PlanningDocumentRelativePath

if (-not (Test-Path -LiteralPath $PlanningDocumentPath)) {
    throw "$PlanningDocumentMissingMessagePrefix $PlanningDocumentPath"
}

$DestinationSkillsPath = Join-Path -Path $ResolvedTargetRepoPath -ChildPath $DestinationSkillsRelativePath
New-Item -Path $DestinationSkillsPath -ItemType Directory -Force | Out-Null

$PlanningDocumentLines = Get-Content -Path $PlanningDocumentPath
$SkillNames = Get-SkillNamesFromPlanningDocument -PlanningDocumentLines $PlanningDocumentLines -ResolvedPlanningDocumentPath $PlanningDocumentPath

if ($SkillNames.Count -eq 0) {
    Write-Host $NoSkillsMessage
    exit 0
}

foreach ($SkillName in $SkillNames) {
    $SourceSkillItem = Get-SourceSkillItem -SkillName $SkillName -ResolvedSourceSkillsRootPath $ResolvedSourceSkillsRootPath
    $DestinationSkillPath = Join-Path -Path $DestinationSkillsPath -ChildPath $SourceSkillItem.Name

    Write-Host "$CopyingSkillMessagePrefix $SkillName..."
    Copy-Item -Path $SourceSkillItem.FullName -Destination $DestinationSkillPath -Recurse -Force
}

Write-Host "$CopiedSkillsMessagePrefix $($SkillNames -join ', ')"
