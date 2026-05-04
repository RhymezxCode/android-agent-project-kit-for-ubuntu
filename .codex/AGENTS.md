# Global Android AGENTS Reference

This is a reusable Android agent instruction file. For best project-level behavior, copy this file into a repository root as `AGENTS.md`.

## Android Standards

- Prefer Kotlin, Jetpack Compose, Material 3, Hilt, Coroutines, Flow, and Navigation Compose.
- Respect existing module boundaries and local patterns before adding abstractions.
- Keep UI, ViewModel, repository, and data source responsibilities separate.
- Do not put business logic in Activities, Fragments, or Composables.
- Use `@HiltViewModel` and constructor injection for ViewModels.
- Expose screen state with `StateFlow`.
- Use `collectAsStateWithLifecycle` for lifecycle-bound flows in Compose.
- Use `rememberSaveable` for user input and state that should survive configuration changes.
- Use stable keys and content types for dynamic lazy list items.
- Add accessibility labels or semantics for meaningful controls.
- Keep touch targets at least 48dp.
- Never hard-code API keys, tokens, passwords, credentials, or secrets.
- Validate input where it crosses trust boundaries or affects network/storage operations.
- Add focused tests for changed behavior, including edge cases and failure scenarios.
- Run relevant Gradle checks and report commands/results.
- Link PRs to the correct GitHub, GitLab, Bitbucket/Jira, Azure DevOps, Linear, or team-tracker issue.

## Planning

Before large or cross-module changes, create a short plan covering target modules/files, approach, data/state flow, edge cases, test commands, and risks. Wait for approval before broad edits.
