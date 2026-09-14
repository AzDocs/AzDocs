@AGENTS.md

# Claude Code notes (Claude-only)

The engineering contract for this repository lives in `AGENTS.md` (imported above and shared with
GitHub Copilot). Nothing below repeats it.

Path-scoped rules in `.github/instructions/*.instructions.md` carry an `applyTo` glob in their front
matter. Copilot applies them automatically; Claude Code does not, so read the ones that match the
files you are about to touch. For a Bicep change that is `bicep-code-best-practices.instructions.md`,
`bicep-property-order.instructions.md` and `azure-naming.instructions.md`.
