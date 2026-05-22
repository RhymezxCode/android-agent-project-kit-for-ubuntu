Param(
    [string]$TargetDir = (Get-Location).Path,
    [string]$Tools = "claude,codex,cursor,github",
    [switch]$KeepAgents,
    [switch]$DryRun,
    [switch]$NoExcludeCleanup
)

$ErrorActionPreference = "Stop"

function Get-NormalizedTools {
    Param([string]$RawTools)

    $AllowedTools = @("claude", "codex", "cursor", "github")
    if ($RawTools -eq "all") {
        return $AllowedTools
    }

    $List = @()
    foreach ($Item in ($RawTools -split ",")) {
        $Tool = $Item.Trim().ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($Tool)) { continue }
        if (-not ($AllowedTools -contains $Tool)) {
            throw "Unsupported tool '$Tool'. Use claude,codex,cursor,github,all."
        }
        if (-not ($List -contains $Tool)) {
            $List += $Tool
        }
    }

    if ($List.Count -eq 0) {
        throw "No valid tools selected."
    }

    return $List
}

function Remove-FileIfExists {
    Param([string]$Path)
    if (-not (Test-Path $Path -PathType Leaf)) { return }

    if ($DryRun) {
        Write-Host "[dry-run] remove $Path"
    } else {
        Remove-Item -Path $Path -Force
    }
}

function Remove-LineFromFile {
    Param(
        [string]$FilePath,
        [string]$Line
    )

    if (-not (Test-Path $FilePath -PathType Leaf)) { return }
    $Lines = Get-Content $FilePath -ErrorAction SilentlyContinue
    if (-not ($Lines -contains $Line)) { return }

    if ($DryRun) {
        Write-Host "[dry-run] remove '$Line' from $FilePath"
        return
    }

    $Filtered = $Lines | Where-Object { $_ -ne $Line }
    Set-Content -Path $FilePath -Value $Filtered
}

function Remove-DirectoryIfEmpty {
    Param([string]$Path)
    if (-not (Test-Path $Path -PathType Container)) { return }
    $Items = Get-ChildItem -Path $Path -Force
    if ($Items.Count -gt 0) { return }

    if ($DryRun) {
        Write-Host "[dry-run] rmdir $Path"
    } else {
        Remove-Item -Path $Path -Force
    }
}

if (-not (Test-Path $TargetDir -PathType Container)) {
    throw "Target directory does not exist: $TargetDir"
}

$SelectedTools = Get-NormalizedTools -RawTools $Tools

if (-not $KeepAgents) {
    Remove-FileIfExists -Path (Join-Path $TargetDir "AGENTS.md")
}

if ($SelectedTools -contains "claude") {
    Remove-FileIfExists -Path (Join-Path $TargetDir ".claude/CLAUDE.md")
    Remove-FileIfExists -Path (Join-Path $TargetDir ".claude/skills/android-agent-standards/SKILL.md")
}

if ($SelectedTools -contains "codex") {
    Remove-FileIfExists -Path (Join-Path $TargetDir ".codex/skills/android-agent-standards/SKILL.md")
}

if ($SelectedTools -contains "cursor") {
    Remove-FileIfExists -Path (Join-Path $TargetDir ".cursor/rules/jetpack-compose-standards.mdc")
    Remove-FileIfExists -Path (Join-Path $TargetDir ".cursor/rules/planning-large-changes.mdc")
}

if ($SelectedTools -contains "github") {
    Remove-FileIfExists -Path (Join-Path $TargetDir ".github/pull_request_template.md")
}

if (-not $DryRun) {
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".claude/skills/android-agent-standards")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".claude/skills")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".claude")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".codex/skills/android-agent-standards")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".codex/skills")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".codex")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".cursor/rules")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".cursor")
    Remove-DirectoryIfEmpty -Path (Join-Path $TargetDir ".github")
}

if ($NoExcludeCleanup) {
    Write-Host "Skipped .git/info/exclude cleanup (--NoExcludeCleanup)."
}
else {
    $ExcludeFile = Join-Path $TargetDir ".git/info/exclude"
    if (Test-Path $ExcludeFile -PathType Leaf) {
        if (-not $KeepAgents) {
            Remove-LineFromFile -FilePath $ExcludeFile -Line "AGENTS.md"
        }
        if ($SelectedTools -contains "claude") { Remove-LineFromFile -FilePath $ExcludeFile -Line ".claude/" }
        if ($SelectedTools -contains "codex") { Remove-LineFromFile -FilePath $ExcludeFile -Line ".codex/" }
        if ($SelectedTools -contains "cursor") { Remove-LineFromFile -FilePath $ExcludeFile -Line ".cursor/" }
        if ($SelectedTools -contains "github") { Remove-LineFromFile -FilePath $ExcludeFile -Line ".github/pull_request_template.md" }
    }
    else {
        Write-Host "No .git/info/exclude file found. Skip exclude cleanup."
    }
}

Write-Host "Uninstalled Android agent kit content from $TargetDir (tools: $($SelectedTools -join ','))."
