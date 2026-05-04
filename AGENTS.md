# Android Project Agent Standards

These instructions apply to agents working in this Android repository.

## Default Android Stack

- Prefer Kotlin, Jetpack Compose, Material 3, Hilt, Coroutines, Flow, and Navigation Compose.
- Follow the existing module boundaries and local patterns before introducing new abstractions.
- Keep changes scoped to the requested feature, bug fix, or refactor.
- Use Gradle Version Catalog dependencies where available.
- Use KSP for annotation processing when adding supported libraries.

## Architecture

- Keep UI, ViewModel, repository, and data source responsibilities separate.
- Do not put business logic in Activities, Fragments, or Composables.
- Use `@HiltViewModel` and constructor injection for ViewModels.
- Expose screen state with `StateFlow`.
- Prefer sealed interfaces or explicit state models for loading, success, empty, and error states.
- Use one-shot events for navigation, snackbars, and transient UI effects.

## Compose

- Collect flows in Composables with `collectAsStateWithLifecycle`.
- Use `rememberSaveable` for user input and state that should survive configuration changes.
- Use `LazyColumn`/`LazyRow` for lists, with stable keys and content types.
- Use Material theme colors and typography instead of hard-coded styling unless matching an approved design.
- Add content descriptions and semantics for interactive or meaningful UI.
- Keep touch targets at least 48dp.
- Add previews for important screens and reusable UI components when practical.

## Security

- Never hard-code API keys, tokens, passwords, credentials, or secrets.
- Treat user data, tokens, and sensitive preferences carefully.
- Use secure storage for sensitive data where applicable.
- Avoid logging sensitive information.
- Validate user input where it crosses trust boundaries or affects network/storage operations.

## Testing And Verification

- Add or update focused tests when behavior changes.
- Cover edge cases and failure scenarios for ViewModels, repositories, and mappers.
- Run the smallest relevant Gradle checks first, then broader checks when shared code is touched.
- Report commands run and whether they passed.

## Pull Requests

- Summarize what changed and why.
- List affected modules and dependencies.
- Include screenshots or screen recordings for UI changes.
- Link the correct issue, ticket, or work item from the project tracker, such as GitHub Issues, GitLab Issues, Bitbucket/Jira, Azure DevOps, Linear, or another team tool.
- Ensure local tests pass before review.
- Confirm CI status once the PR is open.

## Large Changes

Before implementing large or cross-module changes, produce a short plan covering:

- Files/modules likely to change.
- Approach and trade-offs.
- Data/state flow.
- Edge cases and failure handling.
- Test plan.

Wait for approval before making broad edits.
