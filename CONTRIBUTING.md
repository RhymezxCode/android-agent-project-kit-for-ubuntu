# Contributing

Thanks for contributing to the Android Agent Project Kit.

## Scope

Keep this repository focused on reusable, project-agnostic agent standards and installer tooling.

## Local Validation

From repository root:

```bash
bash -n install-to-project.sh
bash -n install-to-project-mac.sh
bash -n uninstall-from-project.sh
bash -n uninstall-from-project-mac.sh
bash -n doctor.sh
bash -n doctor-mac.sh
```

Run a local smoke test (Linux/macOS):

```bash
TMP="$(mktemp -d)"
mkdir -p "$TMP/project"
cd "$TMP/project"
git init -q
/path/to/android-agent-project-kit/install-to-project.sh .
/path/to/android-agent-project-kit/doctor.sh .
/path/to/android-agent-project-kit/uninstall-from-project.sh .
rm -rf "$TMP"
```

Windows contributors should run:

```powershell
powershell -ExecutionPolicy Bypass -File ".\install-to-project-windows.ps1" -TargetDir "."
powershell -ExecutionPolicy Bypass -File ".\doctor-windows.ps1" -TargetDir "."
powershell -ExecutionPolicy Bypass -File ".\uninstall-from-project-windows.ps1" -TargetDir "."
```

## Change Process

1. Keep changes scoped and documented.
2. Update `README.md` when behavior or flags change.
3. Update `CHANGELOG.md` and bump `VERSION` for user-visible changes.
4. Ensure CI smoke tests remain green across Linux/macOS/Windows.
