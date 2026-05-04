---
name: android-agent-standards
description: Global Android engineering standards for Claude. Use for Android, Kotlin, Jetpack Compose, Gradle, PR review, testing, accessibility, and security tasks.
---

# Android Agent Standards

Use these standards for Android work unless project instructions say otherwise.

## Architecture

- Prefer Kotlin, Jetpack Compose, Material 3, Hilt, Coroutines, Flow, and Navigation Compose.
- Respect existing module boundaries and local patterns before adding abstractions.
- Keep UI, ViewModel, repository, and data source responsibilities separate.
- Do not put business logic in Activities, Fragments, or Composables.
- Use `@HiltViewModel` and constructor injection for ViewModels.
- Expose screen state with `StateFlow`.
- Prefer sealed interfaces or explicit state models for loading, success, empty, and error states.
- Use one-shot events for navigation, snackbars, and transient UI effects.

## Compose

- Use `collectAsStateWithLifecycle`, not `collectAsState`, for lifecycle-bound flows.
- Use `rememberSaveable` for user input and state that should survive configuration changes.
- Use `LazyColumn`, `LazyRow`, or paging lazy APIs for lists.
- Provide stable `key` and useful `contentType` values for dynamic lazy list items.
- Use project theme colors and typography instead of arbitrary hard-coded styles.
- Add `contentDescription` or semantics for meaningful images, icons, buttons, and custom click targets.
- Keep interactive touch targets at least 48dp.
- Do not perform network, database, file, or heavy CPU work directly in Composables.

## Security

- Never hard-code API keys, tokens, passwords, credentials, or secrets.
- Avoid logging sensitive information.
- Use secure storage for sensitive data where applicable.
- Validate user input where it crosses trust boundaries or affects network/storage operations.

## Testing And PRs

- Add or update focused tests when behavior changes.
- Cover edge cases and failure scenarios for ViewModels, repositories, mappers, and UI state.
- Run the smallest relevant Gradle checks first, then broader checks when shared code is touched.
- Summarize what changed and why.
- List affected modules and dependencies.
- Include screenshots or recordings for UI changes.
- Link the correct issue, ticket, or work item from GitHub, GitLab, Bitbucket/Jira, Azure DevOps, Linear, or the team tracker.
- Confirm local tests and CI status before review.

## Planning

Before large or cross-module changes, create a short plan covering modules/files, approach, data/state flow, edge cases, test commands, and risks. Wait for approval before broad edits.
