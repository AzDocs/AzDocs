# AzDocs (Azure Documentation) - AI Agent Instructions

## Project Overview

When a user's request does not specify v1 or v2, default to providing the Bicep (v2) implementation. If the user's context (e.g., referencing `src/`, pipeline scripts, or Azure CLI) implies v1, provide the PowerShell implementation. When ambiguous, provide the Bicep implementation and note that a PowerShell equivalent exists in `src/`.

AzDocs is a secure-by-default Azure infrastructure library with dual implementations:

- **AzDocs v1** (`src/`): PowerShell scripts wrapping Azure CLI for imperative deployments
- **AzDocs v2** (`src-bicep/`): Bicep modules for declarative infrastructure-as-code

The repository is designed for Azure DevOps integration, providing compliant, production-ready Azure resources with comprehensive logging, HTTPS enforcement, and centralized diagnostics.

## Copilot Instruction Layering

When generating or modifying PowerShell code, apply the path-specific instruction files in `.github/instructions/`:

- `powershell.instructions.md` for `**/*.ps1` and `**/*.psm1`
- `powershell-pester-5.instructions.md` for `**/*.Tests.ps1`

If both this file and path-specific instruction files apply, follow all applicable rules. For conflicts, prefer the more specific path-targeted instruction.

## Architecture & Organization

### Dual Code Paths

- **PowerShell scripts** (`src/`): Organized by Azure service (e.g., `App-Services/`, `Keyvault/`, `Storage-Accounts/`)
  - Each script is a standalone, importable module
  - Shared utilities in `src/AzDocs.Common/`
- **Bicep modules** (`src-bicep/`): Mirror Azure resource provider structure (e.g., `Storage/`, `Network/`, `Web/`)
  - If a user references a Common/ type file or type name that does not appear in the documented examples, note that you cannot verify the type exists in the repository and recommend the user confirm the exact export name using `@export()` declarations in the relevant Common/ file before committing.
  - Published to Azure Container Registry (ACR) as versioned modules
  - Common type definitions in `src-bicep/Common/` for reusability

### Module Publication System

Bicep modules are automatically published to ACR:

- Registry alias configured in `src-bicep/bicepconfig.json`
- CI/CD via `pipelines/Acr/pipeline-bicep2acr.yml`
- Script: `scripts/Upload-BicepModules.ps1` (parallel publishing with throttling)
- Naming convention: `br:registryname.azurecr.io/{path}/{filename}:latest` or versioned tags
- When generating module consumption examples or scaffolding, always use the `latest` tag. When generating production deployment code or when the user asks for a pinned/stable reference, use the versioned tag format `{yyyy.MM.dd.r}-main` and note that the exact version must be substituted by the developer.
- Each `.bicep` file becomes an importable module
- The publishing takes place through Azure DevOps pipelines. For local testing purposes only, developers may run the publish script manually (see Developer Workflows below), but production publishing is always done via pipelines.

## Critical Development Patterns

### PowerShell Scripts (v1)

**Always use these patterns:**

1. **Import AzDocs.Common module** at the top of every script:

   ```powershell
   #region ===BEGIN IMPORTS===
   Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
   #endregion ===END IMPORTS===
   ```

2. **Use `Invoke-Executable` wrapper** instead of direct Azure CLI calls:

   ```powershell
   # NEVER do this:
   az webapp create --name $name --resource-group $rg

   # ALWAYS do this:
   Invoke-Executable az webapp create --name $name --resource-group $rg
   ```

   **Why:** `Invoke-Executable` ensures pipeline failures on errors, adds structured logging, and auto-appends `--debug` when `$env:SYSTEM_DEBUG` is true.

3. **Script structure template:**

   ```powershell
   [CmdletBinding()]
   param (
       [Parameter(Mandatory)][string] $RequiredParam,
       [Parameter()][string] $OptionalParam
   )

   #region ===BEGIN IMPORTS===
   Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
   #endregion ===END IMPORTS===

   Write-Header -ScopedPSCmdlet $PSCmdlet

   # Script logic here using Invoke-Executable

   Write-Footer -ScopedPSCmdlet $PSCmdlet
   ```

4. **Optional parameters pattern** for Azure CLI:
   ```powershell
   $optionalParameters = @()
   if ($AppServiceSlotName) {
       $optionalParameters += '--slot', "$AppServiceSlotName"
   }
   Invoke-Executable az webapp config hostname add @optionalParameters
   ```

### Bicep Modules (v2)

**Module structure conventions:**

1. **Metadata header** for documentation:

   ```bicep
   metadata name = 'Storage Accounts'
   metadata description = 'This module deploys a Storage Account.'
   ```

2. **Import shared types** from `Common/`:

   ```bicep
   import { diagnosticLogCategory, diagnosticMetricCategory } from '../Common/diagnosticTypes.bicep'
   import { virtualNetworkRule, ipRule } from '../Common/networkTypes.bicep'
   import { roleAssignment } from '../Common/authorizationTypes.bicep'
   ```

3. **Inline documentation** using Synopsis/Description/Example format:

   ```bicep
   /*
   .SYNOPSIS
   Creating a storage account.
   .DESCRIPTION
   Creating a storage account with secure defaults.
   .EXAMPLE
   <pre>
   module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts:latest' = {
     params: {
       storageAccountName: 'mystorageacct'
       location: location
     }
   }
   </pre>
   .LINKS
   - [Bicep Storage Account](https://learn.microsoft.com/...)
   */
   ```

4. **Use `@description()` decorators**: Add a `@description()` decorator to every parameter and output without exception. The description must be a complete sentence explaining the parameter's purpose, accepted values, and any default behavior.
5. **Export types** in Common modules with `@export()` decorator

### Module Consumption Pattern

When using published Bicep modules, reference via ACR alias:

```bicep
module storageaccount 'br:azdocs/storage/storageaccounts:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'stg')
  params: { /* ... */ }
}
```

The `azdocs` alias is defined in `bicepconfig.json`.

## Developer Workflows

### Local Development

- **PowerShell scripts:** Test by dot-sourcing: `. .\src\App-Services\Create-App-Service.ps1 -params`
- **Bicep modules:** Use `az bicep build` to validate syntax before committing

### Publishing Bicep Modules

Automatic on push to `main` branch:

1. Pipeline `pipelines/Acr/pipeline-bicep2acr.yml` triggers on changes to `src-bicep/**/*.bicep`
2. Runs `scripts/Upload-BicepModules.ps1` with parallel processing
3. Tags: `{yyyy.MM.dd.r}-main` for commits, `latest` for main branch
4. Each `.bicep` file → one ACR module artifact

Local testing publish (not for production use):

```powershell
$env:BUILD_SOURCEBRANCHNAME = 'main'
$env:BUILD_BUILDNUMBER = (Get-Date -Format "yyyy.MM.dd.1-") + 'main'
.\scripts\Upload-BicepModules.ps1 -RegistryName 'youracr'
```

### Debugging

Enable verbose Azure CLI output by setting Azure DevOps pipeline variable:

- `System.Debug = true`
  This auto-appends `--debug` to all `Invoke-Executable` calls.

## Key Helper Functions

Located in `src/AzDocs.Common/public/`:

- **Invoke-Executable**: Safe Azure CLI execution with error handling & logging
- **Write-Header/Write-Footer**: Structured logging for Azure DevOps pipelines
- **Write-ColorHost**: Cross-platform colored output (Azure DevOps vs local)
- Helper functions for: AAD, AppGateway, AppInsights, Compliancy, CosmosDb, DiagnosticSettings, Keyvault, Networking, PrivateEndpoint, Vnet, Whitelisting

## Security & Compliance Defaults

All modules enforce:

- HTTPS/TLS: enforced, no override parameter permitted.
- Diagnostic settings: enforced, override via `diagnosticSettingsEnabled` bool parameter defaulting to `true`.
- Private endpoints: enforced. Each Bicep module must include a boolean parameter (e.g., `disablePrivateEndpoint`, defaulting to `false`) that allows callers to opt out of private endpoint enforcement. No additional condition or justification is required at the module level; governance is the caller's responsibility.
- Network whitelisting: enforced, override via `networkAclsDefaultAction` parameter.
- Resource tagging: enforced, no override permitted.

## Documentation

- **Wiki**: Publish `Wiki/` folder as Azure DevOps wiki
- **Bicep docs**: Auto-generated from inline comments using `Tools/Bicep/` scripts. The doc-generation tool supports the following sections inside the `/* */` block: `.SYNOPSIS` (required), `.DESCRIPTION` (required), `.EXAMPLE` with `<pre>` tags (at least one required), and `.LINKS` (optional). Do not add `.PARAMETER` or `.OUTPUTS` sections — these are not parsed by the tooling and will appear as raw text in generated docs.
- **Azure best practices**: See `Wiki/Azure.md` for general guidance

## Common Pitfalls

1. **Don't bypass Invoke-Executable**: Direct `az` calls won't fail pipelines correctly. If the user provides or requests code containing direct `az` CLI calls outside of `Invoke-Executable`, always rewrite those calls to use `Invoke-Executable` and add an inline comment explaining: `# Invoke-Executable ensures pipeline failure propagation and structured logging`. Do not silently accept direct `az` calls even if the user explicitly requests them.
2. **Always import AzDocs.Common**: Scripts fail without the module's helper functions
3. **Registry alias mismatch**: Update `bicepconfig.json` if ACR name changes
4. **Parameter validation**: Use `[Parameter(Mandatory)]` and validation attributes in PowerShell
5. **Case sensitivity**: Bicep imports are case-sensitive on Linux build agents
