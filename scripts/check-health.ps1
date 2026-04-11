param(
    [string]$RepositoryRoot = $(Split-Path -Path $PSScriptRoot -Parent),
    [switch]$RunTestsIfPresent
)

$ErrorActionPreference = 'Stop'

$TbdRelativePath = 'docs/state/tbd.md'
$TbdResponseRelativePath = 'docs/state/tbd-response.md'
$StateDirectoryRelativePath = 'docs/state'
$PackageJsonRelativePath = 'package.json'
$BacklogRelativePath = 'docs/state/backlog.md'
$GitStatusPorcelainArgument = '--porcelain'
$GitStatusCommand = 'status'
$GitRevParseCommand = 'rev-parse'
$GitRepositoryCheckArgument = '--is-inside-work-tree'
$NpmCommand = 'npm'
$NpmTestArgument = 'test'
$NpmRunInBandArgument = '--runInBand'
$ReadySymbolCodePoint = 0x2705
$FixSymbolCodePoint = 0x274C
$ReadyMessage = ([char]$ReadySymbolCodePoint) + ' Ready'
$FixBeforeRunningMessage = ([char]$FixSymbolCodePoint) + ' Fix before running'
$TbdMissingResponseMessage = 'Unresolved blocker: docs/state/tbd.md exists without docs/state/tbd-response.md.'
$StateChangesMessage = 'Uncommitted changes detected under docs/state/.'
$PackageJsonMissingMessage = 'package.json not found; skipped npm test.'
$TestsPassedMessage = 'npm test -- --runInBand passed.'
$TestsRequestedMessage = 'Running npm test -- --runInBand.'
$TestsSkippedMessage = 'Skipped npm test; use -RunTestsIfPresent to enable it when package.json exists.'
$MilestoneReminderMessage = 'All backlog items are complete. Consider tagging a milestone before adding new work.'
$ChecklistPattern = '(?m)^\s*[-*]\s+\[(?<state>[xX ])\]'

function Test-AllBacklogItemsComplete {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    $backlogPath = Join-Path -Path $RepositoryRootPath -ChildPath $BacklogRelativePath
    if (-not (Test-Path -Path $backlogPath)) {
        return $false
    }

    $content = [System.IO.File]::ReadAllText($backlogPath)
    $matches = [System.Text.RegularExpressions.Regex]::Matches($content, $ChecklistPattern)

    if ($matches.Count -eq 0) {
        return $false
    }

    foreach ($match in $matches) {
        if ($match.Groups['state'].Value -eq ' ') {
            return $false
        }
    }

    return $true
}

function Test-GitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    & git -C $RepositoryRootPath $GitRevParseCommand $GitRepositoryCheckArgument | Out-Null
}

function Test-TbdState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    $tbdPath = Join-Path -Path $RepositoryRootPath -ChildPath $TbdRelativePath
    $tbdResponsePath = Join-Path -Path $RepositoryRootPath -ChildPath $TbdResponseRelativePath
    $hasTbd = Test-Path -Path $tbdPath
    $hasTbdResponse = Test-Path -Path $tbdResponsePath

    if ($hasTbd -and (-not $hasTbdResponse)) {
        return $false
    }

    return $true
}

function Get-StateDirectoryChanges {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    $statusOutput = & git -C $RepositoryRootPath $GitStatusCommand $GitStatusPorcelainArgument -- $StateDirectoryRelativePath
    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Test-PackageJsonExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    $packageJsonPath = Join-Path -Path $RepositoryRootPath -ChildPath $PackageJsonRelativePath
    return Test-Path -Path $packageJsonPath
}

function Invoke-NpmTests {
    & $NpmCommand $NpmTestArgument -- $NpmRunInBandArgument
    if ($LASTEXITCODE -ne 0) {
        throw 'npm test failed.'
    }
}

$issues = @()
$notes = @()

Test-GitRepository -RepositoryRootPath $RepositoryRoot

if (-not (Test-TbdState -RepositoryRootPath $RepositoryRoot)) {
    $issues += $TbdMissingResponseMessage
}

$stateChanges = Get-StateDirectoryChanges -RepositoryRootPath $RepositoryRoot
if ($stateChanges.Count -gt 0) {
    $issues += $StateChangesMessage
}

if (Test-AllBacklogItemsComplete -RepositoryRootPath $RepositoryRoot) {
    $notes += $MilestoneReminderMessage
}

$packageJsonExists = Test-PackageJsonExists -RepositoryRootPath $RepositoryRoot
if ($RunTestsIfPresent) {
    if ($packageJsonExists) {
        Write-Host $TestsRequestedMessage
        try {
            Push-Location -Path $RepositoryRoot
            Invoke-NpmTests
            $notes += $TestsPassedMessage
        }
        catch {
            $issues += $_.Exception.Message
        }
        finally {
            Pop-Location
        }
    }
    else {
        $notes += $PackageJsonMissingMessage
    }
}
else {
    $notes += $TestsSkippedMessage
}

foreach ($note in $notes) {
    Write-Host $note
}

if ($issues.Count -gt 0) {
    foreach ($issue in $issues) {
        Write-Host $issue
    }

    Write-Host $FixBeforeRunningMessage
    exit 1
}

Write-Host $ReadyMessage