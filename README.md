# Android Agent Project Kit (Linux + macOS + Windows + Android)

Reusable agent instruction files for Android repositories, designed to work with Codex, Claude, and Cursor workflows.

This guide is for Linux, macOS, and Windows users working on Android projects (usually in Android Studio).

## What This Kit Adds

When installed into an Android project root, this kit adds:

- `AGENTS.md` (repo-level Android coding standards)
- `.claude/CLAUDE.md`
- `.claude/skills/android-agent-standards/SKILL.md`
- `.codex/skills/android-agent-standards/SKILL.md`
- `.cursor/rules/jetpack-compose-standards.mdc`
- `.cursor/rules/planning-large-changes.mdc`
- `.github/pull_request_template.md`
- project maintenance docs:
  - `VERSION`
  - `CHANGELOG.md`
  - `CONTRIBUTING.md`
- Installer scripts:
  - `install-to-project.sh` (Linux/macOS)
  - `install-to-project-mac.sh` (macOS wrapper)
  - `install-to-project-windows.ps1` (Windows PowerShell)
- Audit scripts:
  - `doctor.sh` (Linux/macOS)
  - `doctor-mac.sh` (macOS wrapper)
  - `doctor-windows.ps1` (Windows PowerShell)
- Uninstall scripts:
  - `uninstall-from-project.sh` (Linux/macOS)
  - `uninstall-from-project-mac.sh` (macOS wrapper)
  - `uninstall-from-project-windows.ps1` (Windows PowerShell)

`AGENTS.md` at the repository root is the single global source of truth for agent rules.

## Prerequisites (Linux/macOS/Windows)

- Linux (Ubuntu 22.04+ recommended), macOS, or Windows 10/11
- Linux/macOS: `bash`, `cp`, `mkdir`, `grep` (normally preinstalled)
- Windows: PowerShell 5.1+ (PowerShell 7+ recommended)
- `git` installed
- An existing Android project (Gradle-based)
- Android Studio (recommended for editing/building the app)

Install missing essentials on Ubuntu:

```bash
sudo apt update
sudo apt install -y git
```

Install developer tools on macOS:

```bash
xcode-select --install
```

Install git on Windows (PowerShell):

```powershell
winget install --id Git.Git -e --source winget
```

## Locate The Kit

In this environment, the kit is located at:

```bash
/home/rhymezxcode/android-agent-project-kit
```

If you prefer to reference it as `/android-agent-project-kit`, create a symlink once:

```bash
sudo ln -s /home/rhymezxcode/android-agent-project-kit /android-agent-project-kit
```

Then either path can be used.

## Quick Install (Recommended)

1. Go to your Android project root (the folder that contains `settings.gradle`, `settings.gradle.kts`, or `gradlew`).
2. Run the installer for your OS.

Linux:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh /path/to/your/android-project
```

macOS:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project-mac.sh /path/to/your/android-project
```

Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1" -TargetDir "C:\path\to\your\android-project"
```

If you created the symlink:

```bash
/android-agent-project-kit/install-to-project.sh /path/to/your/android-project
```

macOS with symlink:

```bash
/android-agent-project-kit/install-to-project-mac.sh /path/to/your/android-project
```

If you are already inside the target project root:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh .
```

On macOS:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project-mac.sh .
```

On Windows (inside project root):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1"
```

### Installer Options

Linux/macOS (`install-to-project.sh`, `install-to-project-mac.sh`):

```bash
# Only Codex + Cursor files, no git exclude updates
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh \
  --target /path/to/project \
  --tools codex,cursor \
  --no-exclude

# Preview actions only
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh \
  --target /path/to/project \
  --dry-run

# Backup existing files before overwrite
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh \
  --target /path/to/project \
  --backup-existing
```

Windows (`install-to-project-windows.ps1`):

```powershell
# Only Codex + Cursor files, no git exclude updates
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1" `
  -TargetDir "C:\path\to\project" `
  -Tools "codex,cursor" `
  -NoExclude

# Preview actions only
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1" `
  -TargetDir "C:\path\to\project" `
  -DryRun

# Backup existing files before overwrite
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1" `
  -TargetDir "C:\path\to\project" `
  -BackupExisting
```

## Manual Install (Alternative)

Copy everything from the kit into your Android project root:

```bash
cp -R /home/rhymezxcode/android-agent-project-kit/. /path/to/your/android-project/
```

Use manual copy only if you do not want the script behavior (for example, local git excludes automation).

## What The Installer Script Does

`install-to-project.sh`, `install-to-project-mac.sh`, and `install-to-project-windows.ps1`:

1. Creates required directories under target project (`.claude`, `.codex`, `.cursor`, `.github`).
2. Copies all instruction/template files.
3. If target is a git repository, appends local ignore entries to `.git/info/exclude` for:
   - `AGENTS.md`
   - `.claude/`
   - `.codex/`
   - `.cursor/`
   - `.github/pull_request_template.md`

This keeps helper files local by default so they do not get committed unless you decide otherwise.

Supported install flags:

- `--tools` / `-Tools`: install only selected tool surfaces (`claude,codex,cursor,github` or `all`)
- `--dry-run` / `-DryRun`: print actions without changing files
- `--no-exclude` / `-NoExclude`: skip `.git/info/exclude` updates
- `--backup-existing` / `-BackupExisting`: create timestamped `.bak` copies before overwrite

## Verify Installation

From the target project root:

```bash
ls -la AGENTS.md .claude .codex .cursor .github/pull_request_template.md
```

Check local excludes:

```bash
cat .git/info/exclude
```

Check git status:

```bash
git status --short
```

If excludes were added correctly, those helper files should not appear in default `git status`.

## Doctor (Audit Installation)

Use doctor scripts to verify expected files and `.git/info/exclude` entries:

Linux/macOS:

```bash
/home/rhymezxcode/android-agent-project-kit/doctor.sh /path/to/your/android-project
```

macOS wrapper:

```bash
/home/rhymezxcode/android-agent-project-kit/doctor-mac.sh /path/to/your/android-project
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\doctor-windows.ps1" -TargetDir "C:\path\to\your\android-project"
```

Doctor options:

- `--tools` / `-Tools`: validate only selected tool surfaces
- `--no-exclude-check` / `-NoExcludeCheck`: skip `.git/info/exclude` checks

## Use In Android Studio

1. Open your Android project in Android Studio.
2. Ensure hidden directories are visible in Project view (`.claude`, `.codex`, `.cursor`, `.github`).
3. Keep `AGENTS.md` at repo root so coding agents can discover project instructions.
4. Continue normal Android workflows (`Run`, `Debug`, `Gradle Sync`, tests) as usual.

Note: This kit only adds AI-agent guidance files. It does not change app runtime behavior by itself.

## Design Accuracy (Included Standard)

The kit’s Compose standards now enforce a measurement-first workflow for screenshot/Figma-driven UI:

- measure exact bounds, paddings, gaps, and icon/text sizes before coding
- detect transparent padding in assets before scaling
- use ratio-based constants tied to the design frame
- verify with a reference-size preview and screenshot comparison before delivery

## CI Smoke Tests

This kit includes a cross-platform installer smoke workflow:

- `.github/workflows/installer-smoke-tests.yml`
- Runs on Linux, macOS, and Windows
- Verifies install, doctor, reinstall idempotency, selective tool installs, dry-run behavior, and uninstall cleanup

## Customization

After install, update project-specific details in:

- `AGENTS.md` (module names, build/test commands, team process)
- `.github/pull_request_template.md` (your tracker fields/checklist)

Keep the Android standards sections intact unless your team intentionally uses different conventions.

## Update The Kit In A Project

To refresh an existing project with latest kit content, re-run the installer:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh /path/to/your/android-project
```

On macOS:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project-mac.sh /path/to/your/android-project
```

On Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1" -TargetDir "C:\path\to\your\android-project"
```

Re-running is safe and idempotent for local excludes (it avoids duplicate lines).

## Commit Or Keep Local

Default behavior is local-only (via `.git/info/exclude`).

If you want to commit these files:

1. Edit `.git/info/exclude`
2. Remove the related lines
3. Run `git add AGENTS.md .claude .codex .cursor .github/pull_request_template.md`

## Troubleshooting

`Permission denied` when running installer:

```bash
chmod +x /home/rhymezxcode/android-agent-project-kit/install-to-project.sh
chmod +x /home/rhymezxcode/android-agent-project-kit/install-to-project-mac.sh
chmod +x /home/rhymezxcode/android-agent-project-kit/doctor.sh
chmod +x /home/rhymezxcode/android-agent-project-kit/doctor-mac.sh
chmod +x /home/rhymezxcode/android-agent-project-kit/uninstall-from-project.sh
chmod +x /home/rhymezxcode/android-agent-project-kit/uninstall-from-project-mac.sh
```

PowerShell script is blocked on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\install-to-project-windows.ps1" -TargetDir "C:\path\to\your\android-project"
```

`No such file or directory` for `/android-agent-project-kit`:

- Use full path: `/home/rhymezxcode/android-agent-project-kit`
- Or create the symlink shown above

Files not visible in Android Studio:

- Enable hidden files/folders in your project view

Files still showing in `git status`:

- Confirm target is a git repo (`.git/` exists)
- Confirm exclude entries exist in `.git/info/exclude`

## Uninstall From A Target Project

Linux/macOS:

```bash
/home/rhymezxcode/android-agent-project-kit/uninstall-from-project.sh /path/to/your/android-project
```

macOS wrapper:

```bash
/home/rhymezxcode/android-agent-project-kit/uninstall-from-project-mac.sh /path/to/your/android-project
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\path\to\android-agent-project-kit\uninstall-from-project-windows.ps1" -TargetDir "C:\path\to\your\android-project"
```

Uninstall options:

- `--tools` / `-Tools`: remove only selected tool surfaces
- `--keep-agents` / `-KeepAgents`: keep root `AGENTS.md`
- `--dry-run` / `-DryRun`: preview actions without modifying files
- `--no-exclude-cleanup` / `-NoExcludeCleanup`: keep existing `.git/info/exclude` entries untouched

## Recommended Next Step

After installation, run your project checks to confirm a clean baseline:

```bash
./gradlew test
```

For larger apps, run the module-specific commands your team normally uses.
