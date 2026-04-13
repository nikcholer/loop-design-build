param(
    [string]$RepositoryRoot = $(Split-Path -Path $PSScriptRoot -Parent),
    [string[]]$VerificationCommand = @()
)

$ErrorActionPreference = 'Stop'

$TbdRelativePath = 'docs/state/tbd.md'
$TbdResponseRelativePath = 'docs/state/tbd-response.md'
$BacklogRelativePath = 'docs/state/backlog.md'
$GitStatusPorcelainArgument = '--porcelain'
$GitStatusCommand = 'status'
$GitRevParseCommand = 'rev-parse'
$GitRepositoryCheckArgument = '--is-inside-work-tree'
$ReadySymbolCodePoint = 0x2705
$FixSymbolCodePoint = 0x274C
$ReadyMessage = ([char]$ReadySymbolCodePoint) + ' Ready'
$FixBeforeRunningMessage = ([char]$FixSymbolCodePoint) + ' Fix before running'
$TbdMissingResponseMessage = 'Unresolved blocker: docs/state/tbd.md exists without docs/state/tbd-response.md.'
$RepositoryChangesMessage = 'Uncommitted changes detected in the repository.'
$VerificationPassedMessage = 'Baseline verification command passed.'
$VerificationSkippedMessage = 'Skipped baseline verification; pass -VerificationCommand <command ...> to run project-specific checks.'
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

function Get-RepositoryChanges {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    $statusOutput = & git -C $RepositoryRootPath $GitStatusCommand $GitStatusPorcelainArgument
    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Invoke-VerificationCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$CommandParts,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRootPath
    )

    $commandName = $CommandParts[0]
    $commandArguments = @()

    if ($CommandParts.Count -gt 1) {
        $commandArguments = $CommandParts[1..($CommandParts.Count - 1)]
    }

    Write-Host ('Running baseline verification command: ' + ($CommandParts -join ' '))

    Push-Location -Path $RepositoryRootPath
    try {
        & $commandName @commandArguments
        if ($LASTEXITCODE -ne 0) {
            throw 'Baseline verification command failed.'
        }
    }
    finally {
        Pop-Location
    }
}

$issues = @()
$notes = @()

Test-GitRepository -RepositoryRootPath $RepositoryRoot

if (-not (Test-TbdState -RepositoryRootPath $RepositoryRoot)) {
    $issues += $TbdMissingResponseMessage
}

$repositoryChanges = Get-RepositoryChanges -RepositoryRootPath $RepositoryRoot
if ($repositoryChanges.Count -gt 0) {
    $issues += $RepositoryChangesMessage
}

if (Test-AllBacklogItemsComplete -RepositoryRootPath $RepositoryRoot) {
    $notes += $MilestoneReminderMessage
}

if ($VerificationCommand.Count -gt 0) {
    try {
        Invoke-VerificationCommand -CommandParts $VerificationCommand -RepositoryRootPath $RepositoryRoot
        $notes += $VerificationPassedMessage
    }
    catch {
        $issues += $_.Exception.Message
    }
}
else {
    $notes += $VerificationSkippedMessage
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
