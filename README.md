# Android Agent Project Kit (Ubuntu + Android)

Reusable agent instruction files for Android repositories, designed to work with Codex, Claude, and Cursor workflows.

This guide is for Ubuntu users working on Android projects (usually in Android Studio).

## What This Kit Adds

When installed into an Android project root, this kit adds:

- `AGENTS.md` (repo-level Android coding standards)
- `.claude/CLAUDE.md`
- `.claude/skills/android-agent-standards/SKILL.md`
- `.codex/AGENTS.md`
- `.codex/skills/android-agent-standards/SKILL.md`
- `.cursor/rules/jetpack-compose-standards.mdc`
- `.cursor/rules/planning-large-changes.mdc`
- `.github/pull_request_template.md`

## Prerequisites (Ubuntu)

- Ubuntu 22.04+ (24.04 recommended)
- `bash`, `cp`, `mkdir`, `grep` (normally preinstalled)
- `git` installed
- An existing Android project (Gradle-based)
- Android Studio (recommended for editing/building the app)

Install missing essentials:

```bash
sudo apt update
sudo apt install -y git
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
2. Run:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh /path/to/your/android-project
```

If you created the symlink:

```bash
/android-agent-project-kit/install-to-project.sh /path/to/your/android-project
```

If you are already inside the target project root:

```bash
/home/rhymezxcode/android-agent-project-kit/install-to-project.sh .
```

## Manual Install (Alternative)

Copy everything from the kit into your Android project root:

```bash
cp -R /home/rhymezxcode/android-agent-project-kit/. /path/to/your/android-project/
```

Use manual copy only if you do not want the script behavior (for example, local git excludes automation).

## What The Installer Script Does

`install-to-project.sh`:

1. Creates required directories under target project (`.claude`, `.codex`, `.cursor`, `.github`).
2. Copies all instruction/template files.
3. If target is a git repository, appends local ignore entries to `.git/info/exclude` for:
   - `AGENTS.md`
   - `.claude/`
   - `.codex/`
   - `.cursor/`
   - `.github/pull_request_template.md`

This keeps helper files local by default so they do not get committed unless you decide otherwise.

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

## Use In Android Studio

1. Open your Android project in Android Studio.
2. Ensure hidden directories are visible in Project view (`.claude`, `.codex`, `.cursor`, `.github`).
3. Keep `AGENTS.md` at repo root so coding agents can discover project instructions.
4. Continue normal Android workflows (`Run`, `Debug`, `Gradle Sync`, tests) as usual.

Note: This kit only adds AI-agent guidance files. It does not change app runtime behavior by itself.

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

From the project root, remove kit files manually if no longer needed:

```bash
rm -rf AGENTS.md .claude .codex .cursor .github/pull_request_template.md
```

Also remove matching lines from `.git/info/exclude` if present.

## Recommended Next Step

After installation, run your project checks to confirm a clean baseline:

```bash
./gradlew test
```

For larger apps, run the module-specific commands your team normally uses.
