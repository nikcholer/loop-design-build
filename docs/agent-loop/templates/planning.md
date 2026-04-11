# Target Architecture / Product Requirements

## Domain Overview

Describe the product or system being built, who it serves, and the main workflow the agent must support.

## Data Sources / Requirements

Paste or summarize the raw schema, API contracts, sample payloads, business rules, and any must-have behaviours that define the scope.

## Technical Constraints

List required environments, deployment constraints, coding standards beyond the default harness, performance limits, and any forbidden approaches.

## Preferred Stack

Specify the preferred languages, frameworks, libraries, databases, and tooling. If something is optional, say so explicitly.

## Skills

List optional harness skills to activate using one bullet per skill name from `~/.agents/skills/`.
Leave this section empty if no extra skills are needed.
Example format: `- frontend-design`
After updating this section, run the harness skill injector against the trial repo so the listed skills are copied into `.agents/skills/`.

## Out of Scope

List features, integrations, migrations, or polish work that the agent should avoid during this run.
