param(
    [string]$RepositoryRoot = $(Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'

$BacklogRelativePath = 'docs/state/backlog.md'
$ArchiveRelativePath = 'docs/state/backlog-archive.md'
$SectionPattern = '(?ms)^## [^\n]+.*?(?=^## |\z)'
$ChecklistPattern = '(?m)^\s*[-*]\s+\[(?<state>[xX ])\]'
$HeadingPrefix = '## '
$NewLine = "`n"
$DoubleNewLine = "`n`n"
$ArchiveHeadingTemplate = '## [Archived: {0}] {1}'
$CommitMessageTemplate = 'chore(state): archive completed backlog sections [{0}]'
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)
$NoCompletedSectionsMessage = 'No fully-completed backlog sections found.'
$ArchivedSectionsMessageTemplate = 'Archived {0} backlog section(s) to {1} and committed the state update.'

function Get-NormalizedContent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $content = [System.IO.File]::ReadAllText($Path)
    return $content.Replace("`r`n", $NewLine).Replace("`r", $NewLine)
}

function Get-MarkdownStructure {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $matches = [System.Text.RegularExpressions.Regex]::Matches($Content, $SectionPattern)
    if ($matches.Count -eq 0) {
        return [pscustomobject]@{
            Preamble = $Content
            Sections = @()
        }
    }

    $sections = @()
    foreach ($match in $matches) {
        $sectionText = $match.Value.Trim("`n")
        $sectionParts = $sectionText -split $NewLine, 2
        $headingLine = $sectionParts[0]
        $title = $headingLine.Substring($HeadingPrefix.Length).Trim()
        $body = ''

        if ($sectionParts.Count -gt 1) {
            $body = $sectionParts[1].Trim("`n")
        }

        $sections += [pscustomobject]@{
            Title = $title
            Text = $sectionText
            Body = $body
        }
    }

    return [pscustomobject]@{
        Preamble = $Content.Substring(0, $matches[0].Index)
        Sections = $sections
    }
}

function Test-CompletedBacklogSection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SectionText
    )

    $checklistMatches = [System.Text.RegularExpressions.Regex]::Matches($SectionText, $ChecklistPattern)
    if ($checklistMatches.Count -eq 0) {
        return $false
    }

    foreach ($checklistMatch in $checklistMatches) {
        if ($checklistMatch.Groups['state'].Value -notin @('x', 'X')) {
            return $false
        }
    }

    return $true
}

function New-MarkdownDocument {
    param(
        [string]$Preamble,

        [Parameter(Mandatory = $true)]
        [string[]]$Sections
    )

    $documentParts = @()
    $trimmedPreamble = $Preamble.Trim("`n")

    if (-not [string]::IsNullOrWhiteSpace($trimmedPreamble)) {
        $documentParts += $trimmedPreamble
    }

    foreach ($section in $Sections) {
        if (-not [string]::IsNullOrWhiteSpace($section)) {
            $documentParts += $section.Trim("`n")
        }
    }

    if ($documentParts.Count -eq 0) {
        return $NewLine
    }

    return ([string]::Join($DoubleNewLine, $documentParts) + $NewLine)
}

function Write-Utf8NoBomFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBomEncoding)
}

function Invoke-StateCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath,

        [Parameter(Mandatory = $true)]
        [string[]]$RelativePaths,

        [Parameter(Mandatory = $true)]
        [string]$CommitMessage
    )

    & git -C $RepositoryRootPath rev-parse --is-inside-work-tree | Out-Null
    & git -C $RepositoryRootPath add -- $RelativePaths
    & git -C $RepositoryRootPath commit -m $CommitMessage | Out-Null
}

$BacklogPath = Join-Path -Path $RepositoryRoot -ChildPath $BacklogRelativePath
$ArchivePath = Join-Path -Path $RepositoryRoot -ChildPath $ArchiveRelativePath

if (-not (Test-Path -Path $BacklogPath)) {
    throw "Backlog file not found: $BacklogPath"
}

$backlogStructure = Get-MarkdownStructure -Content (Get-NormalizedContent -Path $BacklogPath)
$completedSections = @()
$activeSections = @()

foreach ($section in $backlogStructure.Sections) {
    if (Test-CompletedBacklogSection -SectionText $section.Text) {
        $completedSections += $section
        continue
    }

    $activeSections += $section.Text
}

if ($completedSections.Count -eq 0) {
    Write-Host $NoCompletedSectionsMessage
    exit 0
}

$archiveDate = Get-Date -Format 'yyyy-MM-dd'
$newArchiveSections = @()

foreach ($completedSection in $completedSections) {
    $archiveHeading = [string]::Format($ArchiveHeadingTemplate, $archiveDate, $completedSection.Title)
    if ([string]::IsNullOrWhiteSpace($completedSection.Body)) {
        $newArchiveSections += $archiveHeading
        continue
    }

    $newArchiveSections += ($archiveHeading + $DoubleNewLine + $completedSection.Body)
}

$existingArchiveContent = ''
if (Test-Path -Path $ArchivePath) {
    $existingArchiveContent = Get-NormalizedContent -Path $ArchivePath
}

$archiveDocumentSections = @()
$trimmedExistingArchive = $existingArchiveContent.Trim("`n")
if (-not [string]::IsNullOrWhiteSpace($trimmedExistingArchive)) {
    $archiveDocumentSections += $trimmedExistingArchive
}
$archiveDocumentSections += $newArchiveSections

$updatedBacklogContent = New-MarkdownDocument -Preamble $backlogStructure.Preamble -Sections $activeSections
$updatedArchiveContent = New-MarkdownDocument -Preamble '' -Sections $archiveDocumentSections

Write-Utf8NoBomFile -Path $BacklogPath -Content $updatedBacklogContent
Write-Utf8NoBomFile -Path $ArchivePath -Content $updatedArchiveContent

$commitMessage = [string]::Format($CommitMessageTemplate, $archiveDate)
Invoke-StateCommit -RepositoryRootPath $RepositoryRoot -RelativePaths @($BacklogRelativePath, $ArchiveRelativePath) -CommitMessage $commitMessage

Write-Host ([string]::Format($ArchivedSectionsMessageTemplate, $completedSections.Count, $ArchiveRelativePath))
