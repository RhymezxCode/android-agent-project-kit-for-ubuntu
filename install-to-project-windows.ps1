Param(
    [string]$TargetDir = (Get-Location).Path,
    [string]$Tools = "claude,codex,cursor,github",
    [switch]$DryRun,
    [switch]$NoExclude,
    [switch]$BackupExisting
)

$ErrorActionPreference = "Stop"
$KitDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Stamp = Get-Date -Format "yyyyMMddHHmmss"

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

function Ensure-Directory {
    Param([string]$Path)
    if ($DryRun) {
        Write-Host "[dry-run] mkdir $Path"
    } else {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Copy-FileWithOptions {
    Param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $DestinationDir = Split-Path -Parent $DestinationPath
    Ensure-Directory -Path $DestinationDir

    if ($BackupExisting -and (Test-Path $DestinationPath -PathType Leaf)) {
        $BackupPath = "$DestinationPath.bak.$Stamp"
        if ($DryRun) {
            Write-Host "[dry-run] copy $DestinationPath $BackupPath"
        } else {
            Copy-Item -Path $DestinationPath -Destination $BackupPath -Force
        }
    }

    if ($DryRun) {
        Write-Host "[dry-run] copy $SourcePath $DestinationPath"
    } else {
        Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
    }
}

if (-not (Test-Path $TargetDir -PathType Container)) {
    throw "Target directory does not exist: $TargetDir"
}

$SelectedTools = Get-NormalizedTools -RawTools $Tools

Copy-FileWithOptions -SourcePath (Join-Path $KitDir "AGENTS.md") -DestinationPath (Join-Path $TargetDir "AGENTS.md")

if ($SelectedTools -contains "claude") {
    Copy-FileWithOptions -SourcePath (Join-Path $KitDir ".claude/CLAUDE.md") -DestinationPath (Join-Path $TargetDir ".claude/CLAUDE.md")
    Copy-FileWithOptions -SourcePath (Join-Path $KitDir ".claude/skills/android-agent-standards/SKILL.md") -DestinationPath (Join-Path $TargetDir ".claude/skills/android-agent-standards/SKILL.md")
}

if ($SelectedTools -contains "codex") {
    Copy-FileWithOptions -SourcePath (Join-Path $KitDir ".codex/skills/android-agent-standards/SKILL.md") -DestinationPath (Join-Path $TargetDir ".codex/skills/android-agent-standards/SKILL.md")
}

if ($SelectedTools -contains "cursor") {
    Copy-FileWithOptions -SourcePath (Join-Path $KitDir ".cursor/rules/jetpack-compose-standards.mdc") -DestinationPath (Join-Path $TargetDir ".cursor/rules/jetpack-compose-standards.mdc")
    Copy-FileWithOptions -SourcePath (Join-Path $KitDir ".cursor/rules/planning-large-changes.mdc") -DestinationPath (Join-Path $TargetDir ".cursor/rules/planning-large-changes.mdc")
}

if ($SelectedTools -contains "github") {
    Copy-FileWithOptions -SourcePath (Join-Path $KitDir ".github/pull_request_template.md") -DestinationPath (Join-Path $TargetDir ".github/pull_request_template.md")
}

if ($NoExclude) {
    Write-Host "Skipped local git exclude updates (--NoExclude)."
}
else {
    $GitDir = Join-Path $TargetDir ".git"
    if (Test-Path $GitDir -PathType Container) {
        $ExcludeFile = Join-Path $GitDir "info/exclude"
        if ($DryRun) {
            Write-Host "[dry-run] ensure file $ExcludeFile"
        } else {
            if (-not (Test-Path $ExcludeFile -PathType Leaf)) {
                New-Item -ItemType File -Path $ExcludeFile -Force | Out-Null
            }
        }

        $Patterns = @("AGENTS.md")
        if ($SelectedTools -contains "claude") { $Patterns += ".claude/" }
        if ($SelectedTools -contains "codex") { $Patterns += ".codex/" }
        if ($SelectedTools -contains "cursor") { $Patterns += ".cursor/" }
        if ($SelectedTools -contains "github") { $Patterns += ".github/pull_request_template.md" }

        $ExistingLines = @()
        if (Test-Path $ExcludeFile -PathType Leaf) {
            $ExistingLines = Get-Content $ExcludeFile -ErrorAction SilentlyContinue
        }

        foreach ($Pattern in $Patterns) {
            if ($ExistingLines -contains $Pattern) { continue }

            if ($DryRun) {
                Write-Host "[dry-run] append '$Pattern' to $ExcludeFile"
            } else {
                Add-Content -Path $ExcludeFile -Value $Pattern
                $ExistingLines += $Pattern
            }
        }

        Write-Host "Updated local git excludes for selected tools."
    }
    else {
        Write-Host "Target is not a git repo, so no local git excludes were added"
    }
}

Write-Host "Installed Android agent kit into $TargetDir (tools: $($SelectedTools -join ','))."
