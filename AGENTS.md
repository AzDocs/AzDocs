# AGENTS.md - AzDocs (Upstream.Azure.PlatformProvisioning)

Single source of engineering instructions for this repository. GitHub Copilot reads
`.github/copilot-instructions.md`, Claude Code reads `CLAUDE.md`; both point here, so the guidance
never diverges.

This file holds what an agent must know before it writes anything. Detail lives in the wiki and in
`.github/instructions/`, and loads on demand.

## What this repository is

AzDocs is a secure-by-default Azure infrastructure library with two implementations:

- **v1** (`src/`): PowerShell scripts wrapping Azure CLI, imperative.
- **v2** (`src-bicep/`): Bicep modules, declarative, published to Azure Container Registry.

When a request does not say which, answer with v2 Bicep and note that a PowerShell equivalent may
exist in `src/`. Context decides: a request mentioning `src/`, pipeline scripts or Azure CLI means v1.

`src-bicep/` mirrors the Azure resource provider structure, so `Microsoft.Cache/redis` lives in
`src-bicep/Cache/redis.bicep`. Shared types live in `src-bicep/Common/` and are exported with
`@export()`.

## Read the code before the guidance

The wiki and these instructions describe intent. The 223 modules in `src-bicep/` describe practice,
and where the two disagree, **practice wins**. Several documented rules turned out to describe
something that was never built. Counts below were measured across all 223 modules, so you can
re-measure rather than trust this page.

| Rule you may read somewhere | Modules that follow it | What to actually do |
| --- | --- | --- |
| Add a `forcePublic` switch | 0 | Use `publicNetworkAccess` with `@allowed(['Enabled','Disabled'])`, default `Disabled` (24 modules) |
| Add a `disablePrivateEndpoint` parameter | 0 | Private endpoints stay the default posture, but a separate module builds them (see below) |
| Override diagnostics with `diagnosticSettingsEnabled` | 0 | Take `logAnalyticsWorkspaceResourceId string?` and guard with `if (!empty(...))` (28 modules) |
| Override whitelisting with `networkAclsDefaultAction` | 1 | Follow the resource, there is no general pattern |
| Open with a `metadata name =` header | 19 | Use the `/* .SYNOPSIS ... */` block (186 modules) |
| Update `Wiki/Azure/CHANGELOG.md` | last touched May 2023 | Skip it. It documents v1 PowerShell scripts and no v2 module has updated it |

Before following any rule in `Wiki/Azure/AzDocs-v2/General-Documentation/`, check it the same way:

```bash
grep -rl 'theParameterName' src-bicep --include=*.bicep | wc -l
```

A rule that no module follows is a proposal, not a convention. Say so rather than being the first to
follow it.

## Writing a module

**Structure, in this order:** the `/* */` documentation block, imports, user-defined types,
parameters, variables, resources, outputs. Section banners
(`// ========== Parameters ==========`) separate them.

**The documentation block is parsed**, it is not a comment. `Tools/Bicep/` generates the wiki page
from it. Supported sections: `.SYNOPSIS` (required), `.DESCRIPTION` (required), `.EXAMPLE` wrapped in
`<pre>` tags (at least one required), `.LINKS` (optional). Do **not** write `.PARAMETER` or
`.OUTPUTS`; the tool does not parse them and they land in the wiki as raw text. Parameter
documentation comes from `@description()` decorators instead.

**Every parameter and every output carries an `@description()`.** No exceptions. It is a full
sentence covering purpose, accepted values and default behaviour, and it becomes the wiki table.

**Name parameters for what they are, not what they are in this file.** `storageAccountName`, not
`name`. When a module creates a parent and a child, prefix the child's parameters too:
`redisEnterpriseDatabasePort`, not `port`. A caller sees the parameter without the surrounding file.

**Secure by default.** TLS at 1.2 or higher with no override, public network access disabled unless
the caller opts in, access keys disabled where Entra authentication exists, tags supported,
diagnostics available through `logAnalyticsWorkspaceResourceId`.

**Validate with decorators** where the platform has limits: `@allowed()`, `@minLength()`,
`@maxLength()`, `@minValue()`, `@maxValue()`.

**Check the API version exists before pinning it.** The Bicep types shipped with the CLI can lag or
lead the provider. `az provider show -n <Namespace> --query "resourceTypes[?resourceType=='<type>'].apiVersions[]" -o tsv`
lists what the tenant actually accepts. Prefer a stable version over a preview one, and compile
before committing: a property that only exists in a newer preview fails as `BCP037`.

### Private endpoints are the default, but a separate module builds them

Every resource that can have a private endpoint is expected to get one. Private connectivity is the
default posture here, not an option a caller enables.

What that does **not** mean is building the endpoint into the resource module. Exactly one module
declares `Microsoft.Network/privateEndpoints`, and that is `src-bicep/Network/privateEndpoints.bicep`
itself. Every other module leaves the endpoint to the caller, who deploys the resource module and
the private endpoint module side by side and wires them together. So do not add
`disablePrivateEndpoint` or any other private endpoint parameter to a resource module: there is no
such parameter anywhere, and the checklist that asks for one describes something that was never
built.

What a resource module **must** do is make that pairing possible and make the private path the
default:

- Default `publicNetworkAccess` to `Disabled`, so a caller who forgets the endpoint gets an
  unreachable resource rather than a public one.
- Output the resource id, because the private endpoint module needs it as `targetResourceId`.
- Document the private endpoint subresource (group id) in the module's `.EXAMPLE` or `.LINKS` when it
  is not obvious. It is not always the resource name: `Microsoft.Cache/redis` uses `redisCache` while
  `Microsoft.Cache/redisEnterprise` uses `redisEnterprise`, and the wrong one fails at runtime rather
  than at deploy time.

Four modules take a `subnetId` for VNet injection, which is a different mechanism and does belong to
the resource.

### Child resources get their own submodule too

When a resource has a child that a caller may need to add on its own later, ship both: the parent
module that can create children inline, and a standalone submodule under a folder named after the
parent. `src-bicep/Cache/redis.bicep` with `src-bicep/Cache/redis/accessPolicyAssignments.bicep` is
the pattern.

This matters more than it looks. Without the submodule, a consuming repository has to declare the
child resource inline, which is exactly what consuming this library is supposed to avoid. The
standalone module takes the parent's name, fetches it with `existing`, and attaches the child.

## Publishing

`pipelines/Acr/pipeline-bicep2acr.yml` runs `scripts/Upload-BicepModules.ps1`, which walks every
`.bicep` file under `src-bicep/` and publishes each one as its own ACR artifact.

**The path becomes the module name**, lowercased, with `/` separators:
`src-bicep/Cache/redisEnterprise.bicep` publishes as `cache/redisenterprise`, and
`src-bicep/Cache/redisEnterprise/accessPolicyAssignments.bicep` as
`cache/redisenterprise/accesspolicyassignments`.

**The build number is the tag**: `{yyyy.MM.dd}{.r}-{Build.SourceBranchName}`. `main` additionally
publishes `latest`.

**Branches publish too, and this is the useful part.** Running the pipeline on a feature branch
gives a real, consumable tag, so a consuming repository can integrate against the module before it
merges. A branch called `feature/managed-redis-module` produces
`2026.09.14.1-managed-redis-module`, because `Build.SourceBranchName` is the last path segment.
Wait for the run to finish before referencing the tag; the artifact does not exist until it does, and
a consumer fails with `BCP192: The artifact does not exist in the registry`.

In consumption examples use `latest`. In production code pin the versioned tag.

## Generating the wiki

`Tools/Bicep/Get-BicepMetadata.ps1` and `Tools/Bicep/Update-MetadataMarkdown.ps1` generate
`Wiki/Azure/AzDocs-v2/Modules/` from the modules.

**Pass absolute paths to both, and pass a directory to `-Path`, not a file.** `Get-BicepMetadata`
does a `Set-Location` to `-Path` and does not restore it, so a relative `-DestinationPath` resolves
against the new location and the write lands somewhere else entirely. `Update-MetadataMarkdown`
deletes the target tree before it writes, so a failed write leaves the wiki deleted rather than
unchanged. A single wrong invocation removed 221 pages.

```powershell
. .\Tools\Bicep\Get-BicepMetadata.ps1
. .\Tools\Bicep\Update-MetadataMarkdown.ps1
$metadata = Get-BicepMetadata -Path 'C:\full\path\to\src-bicep'
Update-MetadataMarkdown -Metadata $metadata -DestinationPath 'C:\full\path\to\Wiki\Azure\AzDocs-v2\Modules'
```

Run it over the whole tree and commit only the pages your change touched; regenerating produces no
diff for modules you did not edit. Check `git status` before staging.

## Writing PowerShell (v1)

Import the shared module and route every Azure CLI call through `Invoke-Executable`:

```powershell
#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet
Invoke-Executable az webapp create --name $name --resource-group $rg
Write-Footer -ScopedPSCmdlet $PSCmdlet
```

A bare `az` call does not fail the pipeline on error and produces no structured logging. Rewrite one
into `Invoke-Executable` even when asked for the bare call, and say why.

Build optional CLI arguments as an array and splat them:

```powershell
$optionalParameters = @()
if ($AppServiceSlotName) { $optionalParameters += '--slot', "$AppServiceSlotName" }
Invoke-Executable az webapp config hostname add @optionalParameters
```

Declare parameters with `[CmdletBinding()]`, `[Parameter(Mandatory)]` and validation attributes.

The helpers live in `src/AzDocs.Common/public/`: `Invoke-Executable` for CLI calls,
`Write-Header` and `Write-Footer` for pipeline-structured logging, `Write-ColorHost` for output that
works both in Azure DevOps and locally, plus helpers for AAD, AppGateway, AppInsights, Compliancy,
CosmosDb, DiagnosticSettings, Keyvault, Networking, PrivateEndpoint, Vnet and Whitelisting. Look
there before writing a new one.

To debug a pipeline run, set the Azure DevOps variable `System.Debug` to `true`. Every
`Invoke-Executable` call then appends `--debug` on its own.

Test a script locally by dot-sourcing it: `. .\src\App-Services\Create-App-Service.ps1 -params`.

## Naming Azure resources

Names come from the Microsoft Cloud Adoption Framework abbreviation list, which is the authority the
naming convention page defers to. Look the resource type up there rather than inventing a prefix;
`Microsoft.Cache/RedisEnterprise` is `amr`, which is not guessable from the resource type.

Format: `<abbreviation>-<purpose>-<environmentType>`, all lowercase, dashes not spaces, environment
type always last (`lab`, `dev`, `tst`, `acc`, `prd`). Omit the region when it is West Europe.

Full rules: `Wiki/Azure/AzDocs-v2/General-Documentation/Naming-convention.md` and
`.github/instructions/azure-naming.instructions.md`.

## Where the detail lives

- **Module guidelines and checklist**: `Wiki/Azure/AzDocs-v2/General-Documentation/Guidelines-for-creating-new-modules.md`
- **Naming**: `Wiki/Azure/AzDocs-v2/General-Documentation/Naming-convention.md`
- **Generated module reference**: `Wiki/Azure/AzDocs-v2/Modules/`
- **Path-scoped agent rules**: `.github/instructions/` - Bicep style and property order, Azure naming, pipeline YAML, PowerShell and Pester. Where a path-scoped file and this one disagree, the path-scoped file wins for files it targets.

## Common pitfalls

1. **Bicep imports are case-sensitive on Linux build agents.** It compiles on Windows and fails in CI.
2. **Do not bypass `Invoke-Executable`** in v1 scripts.
3. **Do not trust a documented parameter name** without grepping for it first; several do not exist.
4. **Do not run the wiki generator with relative paths.** It deletes before it writes.
5. **Do not reference a branch module tag before its pipeline run finishes.**
6. **Verify the API version against the provider**, not against the Bicep types alone.
