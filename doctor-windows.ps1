Param(
    [string]$TargetDir = (Get-Location).Path,
    [string]$Tools = "claude,codex,cursor,github",
    [switch]$NoExcludeCheck
)

$ErrorActionPreference = "Stop"
$PassCount = 0
$FailCount = 0
$WarnCount = 0

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

function Check-FileExists {
    Param([string]$Path)
    if (Test-Path $Path -PathType Leaf) {
        Write-Host "[PASS] $Path exists"
        $script:PassCount++
    } else {
        Write-Host "[FAIL] $Path is missing"
        $script:FailCount++
    }
}

function Check-ExcludeLine {
    Param(
        [string]$FilePath,
        [string]$Line
    )

    $Lines = Get-Content $FilePath -ErrorAction SilentlyContinue
    if ($Lines -contains $Line) {
        Write-Host "[PASS] $FilePath contains '$Line'"
        $script:PassCount++
    } else {
        Write-Host "[FAIL] $FilePath missing '$Line'"
        $script:FailCount++
    }

    $Count = ($Lines | Where-Object { $_ -eq $Line }).Count
    if ($Count -le 1) {
        Write-Host "[PASS] $FilePath has <=1 '$Line' entry"
        $script:PassCount++
    } else {
        Write-Host "[FAIL] $FilePath has duplicate '$Line' entries ($Count)"
        $script:FailCount++
    }
}

if (-not (Test-Path $TargetDir -PathType Container)) {
    throw "Target directory does not exist: $TargetDir"
}

$SelectedTools = Get-NormalizedTools -RawTools $Tools

Write-Host "Doctor target: $TargetDir"
Write-Host "Expected tools: $($SelectedTools -join ',')"
Write-Host ""

Check-FileExists -Path (Join-Path $TargetDir "AGENTS.md")

if ($SelectedTools -contains "claude") {
    Check-FileExists -Path (Join-Path $TargetDir ".claude/CLAUDE.md")
    Check-FileExists -Path (Join-Path $TargetDir ".claude/skills/android-agent-standards/SKILL.md")
}
if ($SelectedTools -contains "codex") {
    Check-FileExists -Path (Join-Path $TargetDir ".codex/skills/android-agent-standards/SKILL.md")
}
if ($SelectedTools -contains "cursor") {
    Check-FileExists -Path (Join-Path $TargetDir ".cursor/rules/jetpack-compose-standards.mdc")
    Check-FileExists -Path (Join-Path $TargetDir ".cursor/rules/planning-large-changes.mdc")
}
if ($SelectedTools -contains "github") {
    Check-FileExists -Path (Join-Path $TargetDir ".github/pull_request_template.md")
}

if (-not $NoExcludeCheck) {
    $ExcludeFile = Join-Path $TargetDir ".git/info/exclude"
    if (Test-Path $ExcludeFile -PathType Leaf) {
        $Patterns = @("AGENTS.md")
        if ($SelectedTools -contains "claude") { $Patterns += ".claude/" }
        if ($SelectedTools -contains "codex") { $Patterns += ".codex/" }
        if ($SelectedTools -contains "cursor") { $Patterns += ".cursor/" }
        if ($SelectedTools -contains "github") { $Patterns += ".github/pull_request_template.md" }

        foreach ($Pattern in $Patterns) {
            Check-ExcludeLine -FilePath $ExcludeFile -Line $Pattern
        }
    }
    else {
        Write-Host "[WARN] .git/info/exclude not found; skipped exclude checks."
        $WarnCount++
    }
}

Write-Host ""
Write-Host "Summary: $PassCount passed, $FailCount failed, $WarnCount warnings."

if ($FailCount -gt 0) {
    exit 1
}
