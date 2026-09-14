# AzDocs - AI Agent Instructions

The engineering contract for this repository lives in [`AGENTS.md`](../AGENTS.md) in the repository
root. Read it before writing anything.

It is the single source for both GitHub Copilot and Claude Code, so the two never diverge. This file
and `CLAUDE.md` only point at it.

## Path-scoped rules

The files in `.github/instructions/` carry an `applyTo` glob and are applied automatically to the
files they target:

| File | Applies to |
| --- | --- |
| `bicep-code-best-practices.instructions.md` | `**/*.bicep` |
| `bicep-property-order.instructions.md` | `**/*.bicep` |
| `azure-naming.instructions.md` | Bicep, Terraform and infra paths |
| `azure-devops-pipelines.instructions.md` | pipeline YAML |
| `powershell.instructions.md` | `**/*.ps1`, `**/*.psm1` |
| `powershell-pester-5.instructions.md` | `**/*.Tests.ps1` |

Where a path-scoped file and `AGENTS.md` disagree, the path-scoped file wins for the files it
targets. Everything else follows `AGENTS.md`.
