param(
    [ValidateSet('grok', 'claude', 'gemini', 'codex', 'aider', 'opencode')]
    [string]$Provider = 'grok',

    [int]$MaxRuns = 3,

    [string]$Command = '',

    [string]$RepositoryRoot = $(Split-Path -Path $PSScriptRoot -Parent),

    [switch]$WaitForResponse
)

$ErrorActionPreference = 'Stop'

$LoopPrompt = 'Read .agents/skills/agent-loop.md and execute the next run strictly from the repository''s local markdown state.'

$ProviderCommands = @{
    grok     = "grok -p `"$LoopPrompt`" --always-approve --max-turns 15"
    claude   = "claude -p `"$LoopPrompt`" --dangerously-skip-permissions --max-turns 15"
    gemini   = "gemini -m gemini-2.5-pro --approval-mode yolo -p `"$LoopPrompt`""
    codex    = "codex exec --dangerously-bypass-approvals-and-sandbox `"$LoopPrompt`""
    aider    = "aider -m `"$LoopPrompt`" --yes --no-gitignore"
    opencode = "opencode run --dangerously-skip-permissions --log-level WARN `"$LoopPrompt`""
}

if ($MaxRuns -lt 1) {
    throw '-MaxRuns must be a positive integer.'
}

$resolvedCommand = if ([string]::IsNullOrWhiteSpace($Command)) { $ProviderCommands[$Provider] } else { $Command }
$tbdPath = Join-Path -Path $RepositoryRoot -ChildPath 'docs/state/tbd.md'
$tbdResponsePath = Join-Path -Path $RepositoryRoot -ChildPath 'docs/state/tbd-response.md'
$healthScript = Join-Path -Path $PSScriptRoot -ChildPath 'check-health.ps1'

function Test-TbdBlocksRun {
    return (Test-Path -Path $tbdPath) -and -not (Test-Path -Path $tbdResponsePath)
}

function Test-TbdPairReady {
    return (Test-Path -Path $tbdPath) -and (Test-Path -Path $tbdResponsePath)
}

function Get-RepositoryChanges {
    $statusOutput = & git -C $RepositoryRoot status --porcelain
    if ($LASTEXITCODE -ne 0) {
        throw "git status failed (exit $LASTEXITCODE). Cannot treat the worktree as clean."
    }
    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Wait-ForTbdResponse {
    Write-Host 'Waiting for docs/state/tbd-response.md ... (Ctrl+C to stop)'
    while (-not (Test-Path -Path $tbdResponsePath)) {
        Start-Sleep -Seconds 5
    }
}

function Stop-DirtyAfterSuccess {
    Write-Host 'Stop: provider exited 0 but left uncommitted changes. Treat this as a harness failure, not a green run.'
    foreach ($line in (Get-RepositoryChanges)) {
        Write-Host "  $line"
    }
    exit 1
}

for ($run = 1; $run -le $MaxRuns; $run++) {
    if (Test-TbdBlocksRun) {
        Write-Host "Stop: unresolved TBD at docs/state/tbd.md (before run $run)."
        if ($WaitForResponse) {
            Wait-ForTbdResponse
        } else {
            exit 0
        }
    }

    if (-not (Test-TbdPairReady)) {
        & $healthScript -RepositoryRoot $RepositoryRoot
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    }

    Write-Host "`n=== Loop run $run of $MaxRuns ==="
    Push-Location -Path $RepositoryRoot
    try {
        & cmd.exe /c $resolvedCommand
        if ($LASTEXITCODE -ne 0) {
            throw "Provider command exited with status $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }

    if (Test-TbdBlocksRun) {
        Write-Host 'Stop: agent published docs/state/tbd.md. Resolve it before the next run.'
        if ($WaitForResponse -and $run -lt $MaxRuns) {
            Wait-ForTbdResponse
            continue
        }
        exit 0
    }

    if ((Get-RepositoryChanges).Count -gt 0) {
        Stop-DirtyAfterSuccess
    }
}

Write-Host "Completed $MaxRuns successful run(s). Outer loop stopped at the --max-runs cap."
