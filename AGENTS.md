# AGENTS.md

## Project

EL GOAT is a football gameplay experiment built with Godot 4.x.

The project prioritizes gameplay iteration, learning, maintainability, and modularity over premature scope expansion.

We are working as a team: the developer, the assistant, and Codex.

---

## Core Principle

Codex has autonomy over technical implementation, but not over game design, project scope, or important product decisions.

The goal is to use Codex as a technical partner while keeping design intent and important decisions under human control.

---

## Authority

The following have the highest authority:

1. Explicit instructions given by the developer during the current conversation.
2. This `AGENTS.md`.

An explicit instruction may intentionally override a rule in this file.

If that happens, follow the explicit instruction and briefly point out the conflict when useful.

Then, in order:

3. `GAME_DESIGN.md`
4. Existing project architecture and conventions.
5. Codex implementation preferences.

Do not invent new project rules when existing rules already provide guidance.

---

## Autonomy and Decision Making

Codex should make implementation decisions autonomously when they do not change the intended behavior, game design, or project scope.

For trivial or objectively better technical decisions, proceed without asking.

For this project, "objectively better" means:

- consistent with established project rules;
- simpler or clearer;
- does not change intended behavior;
- does not expand scope;
- does not introduce unnecessary complexity.

When there is a meaningful trade-off, present concise alternatives, recommend one, explain the main gains and losses, mention relevant implementation cost, and wait for approval when the decision affects design, architecture, behavior, or scope.

Do not ask for approval over trivial implementation details.

---

## Scope

Before expanding the scope of a task, first attempt to solve the problem within the existing scope.

If that is not reasonably possible:

- explain what needs to change;
- explain why;
- present alternatives when useful;
- wait for approval before proceeding outside the original scope.

Do not add features merely because they seem useful.

---

## Existing Behavior and Regressions

Preserve existing behavior unless the task explicitly changes it.

If a regression is clearly caused by the current change, fix it autonomously.

If the cause is uncertain, report it.

If fixing it requires changing established behavior, architecture, or scope, ask for approval.

---

## Subjective Feedback

Treat subjective feedback as a valid instruction.

For feedback such as "the movement feels too rigid":

1. make the smallest reasonable adjustment;
2. let the result be evaluated;
3. iterate based on feedback.

Do not interpret a small qualitative adjustment as permission for a large redesign.

If the intent remains unclear after a reasonable first adjustment, ask for clarification.

---

## Engineering Principles

Follow these principles:

- DRY
- KISS
- YAGNI
- clear separation of responsibilities
- maintainability
- consistency
- avoid premature abstraction
- avoid unnecessary coupling
- avoid magic strings
- use constants and enums when appropriate

Do not apply DRY mechanically when it would increase complexity.

Consistency is a project-wide priority.

---

## Godot

Use idiomatic Godot 4.x patterns and best practices.

Do not blindly transfer patterns from unrelated technologies when they do not fit Godot naturally.

Maintain the same professional engineering standards regardless of technology.

Prefer simple, maintainable solutions appropriate to the current scope.

---

## Refactoring

Do not perform unrelated refactors during a task merely because the code could be improved.

If a relevant refactor is not necessary for the current task:

- leave the existing code intact;
- record the improvement as future work when appropriate;
- prioritize it before accumulating significant additional complexity when it could affect future work.

Do not turn minor stylistic preferences into unnecessary refactoring tasks.

---

## Testing

Add tests when they provide meaningful value, especially for:

- deterministic logic;
- gameplay rules;
- calculations;
- evaluators;
- systems with clear inputs and outputs.

Do not add tests merely for coverage or quantity.

When introducing meaningful tests, briefly explain what behavior they protect.

The architecture should avoid unnecessarily preventing future QA automation, but no QA automation framework should be introduced prematurely.

---

## Localization

Design user-facing text with future localization in mind from the beginning.

Avoid scattering hard-coded user-facing strings throughout gameplay code.

Use Godot's localization mechanisms appropriately without building unnecessary localization infrastructure before it is needed.

---

## Learning Mode

When introducing a new technical concept, identify the first relevant file before implementing it.

The first file introducing a new concept should contain useful educational comments explaining:

- its responsibility;
- why it exists;
- important implementation decisions;
- relevant Godot concepts.

Educational comments intended to teach the developer must be written in Spanish.

Do not repeat educational comments throughout subsequent files implementing the same concept.

Comments should explain non-obvious reasoning, not restate obvious code.

Code, identifiers, APIs, constants, enums, and other technical naming should follow the conventions of Godot and the language rather than being translated for the sake of the comments.

---

## Git

Codex must not create commits without approval.

After completing a coherent task:

1. review the changes;
2. propose a clear commit message;
3. summarize what the commit contains;
4. wait for approval;
5. create the commit after approval.

Keep commits focused and avoid mixing unrelated changes.

---

## Documentation

`AGENTS.md` is the project collaboration contract.

Codex may suggest changes to it but must not modify it without approval.

`GAME_DESIGN.md` contains game design decisions.

Important gameplay rules and design decisions require human approval.

Technical documentation may be created or updated when it provides meaningful value.

---

## Task Completion

After completing a task, provide a concise summary proportional to the complexity of the work.

Mention relevant items such as:

- what changed;
- important decisions;
- tests performed;
- issues discovered;
- technical debt or follow-up work;
- anything requiring attention;
- suggested commit message.

Do not produce unnecessary reports for trivial changes.

---

## Communication

Do not narrate every implementation step.

Work autonomously and communicate when:

- a decision requires human input;
- an important ambiguity is discovered;
- the task would need to expand beyond its scope;
- an existing project rule is affected;
- a significant issue is discovered.

Prefer concise, useful communication.

---

## Destructive Actions

Normal commands required for development, analysis, and testing may be executed autonomously.

Explicit approval is required before performing destructive, irreversible, or potentially high-impact actions affecting:

- Git history;
- project data;
- important files;
- dependencies;
- important configuration.

When uncertain whether an action is destructive or high-impact, ask before executing it.