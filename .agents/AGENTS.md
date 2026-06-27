# AGENTS.md — SwissArmyKnife Agent Rules

## Code Style
- Follow `package:lints` rules strictly
- All public members must have `///` dartdoc comments
- Prefer `extension type` for new extension groups
- Use `sealed class` for sum types (Result, Option, Either)
- Max line length: 80 characters
- Always use trailing commas in multi-line collections and parameter lists

## File Organization
- One extension group per file
- One pattern/utility per file
- Barrel exports only — never import from `src/` directly
- Tests mirror the `src/` directory structure

## Naming Conventions
- Extensions: `StringKnife`, `NumKnife`, `DateTimeKnife`, etc.
- Classes: PascalCase, descriptive names
- Private helpers: prefixed with `_`
- Test files: `<module>_test.dart`

## API Design Rules
- Default parameters should cover 90% of use cases
- Provide both sync and async variants where applicable
- Use `factory` constructors for named construction patterns
- Extension methods should feel like native Dart methods
- Never throw from extension methods — return nullable or use Result type

## Testing Rules
- Every public method must have at least 2 test cases
- Test both happy path and edge cases
- Group tests by feature using `group()`
- Use descriptive test names: `'should return empty string when input is null'`

## Documentation Rules
- Every file must start with a `/// Library-level` comment
- Include at least one usage example in every class/extension doc
- Cross-reference related utilities in doc comments
