# Contributing to Loop-Design-Build

Thank you for your interest in improving the Agentic Loop Harness! We welcome contributions that make the harness more robust, the templates more descriptive, or the documentation clearer.

## How to Contribute

1. **Suggest Template Refinements**: If you find that the agent is consistently misinterpreting a specific section of the state files, please suggest a change to the matching template in `docs/agent-loop/templates/`.
2. **Improve Playbooks**: If the human operator instructions are ambiguous or missing a common maintenance step, updates to `outer-loop-playbook.md` are highly valued.
3. **Enhance Tooling**: Improvements to the PowerShell scripts for scaffolding or health-checking are welcome. Please ensure scripts remain cross-platform (PowerShell Core) where possible.
4. **Report Bugs**: If the core `skill.md` logic leads to a loop failure or state corruption, please open an issue describing the failure mode and the provider used.

## Contribution Standards

- **Maintain Generality**: The harness is designed to be provider-agnostic and project-independent. Avoid adding stack-specific rules to the core `skill.md` or templates.
- **TDD First**: If contributing code, ensure that the change is accompanied by a verification path.
- **Keep it Lightweight**: The value of this harness is its simplicity and reliance on local markdown state. Avoid adding heavy orchestration or complex dependency chains.

## License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
