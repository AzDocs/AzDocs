# AzDocs (Azure Documentation) - AI Agent Instructions

## Project Overview

AzDocs is a secure-by-default Azure infrastructure library with dual implementations:

- **AzDocs v1** (`src/`): PowerShell scripts wrapping Azure CLI for imperative deployments
- **AzDocs v2** (`src-bicep/`): Bicep modules for declarative infrastructure-as-code

The repository is designed for Azure DevOps integration, providing compliant, production-ready Azure resources with comprehensive logging, HTTPS enforcement, and centralized diagnostics.

## Architecture & Organization

### Dual Code Paths

- **PowerShell scripts** (`src/`): Organized by Azure service (e.g., `App-Services/`, `Keyvault/`, `Storage-Accounts/`)
  - Each script is a standalone, importable module
  - Shared utilities in `src/AzDocs.Common/`
- **Bicep modules** (`src-bicep/`): Mirror Azure resource provider structure (e.g., `Storage/`, `Network/`, `Web/`)
  - Published to Azure Container Registry (ACR) as versioned modules
  - Common type definitions in `src-bicep/Common/` for reusability

### Module Publication System

Bicep modules are automatically published to ACR:

- Registry alias configured in `src-bicep/bicepconfig.json`
- CI/CD via `pipelines/Acr/pipeline-bicep2acr.yml`
- Script: `scripts/Upload-BicepModules.ps1` (parallel publishing with throttling)
- Naming convention: `br:registryname.azurecr.io/{path}/{filename}:latest` or versioned tags
- Each `.bicep` file becomes an importable module
- The publishing takes place through Azure DevOps pipelines. We don't manually publish modules to ACR.

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

4. **Use `@description()` decorators** extensively for all parameters
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

Manual publish:

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

- HTTPS/TLS by default
- Centralized logging to Log Analytics Workspace (via diagnostic settings)
- Private communication (private endpoints for example) for service isolation by default. There should be an option through parameters to disable this if necessary.
- Network whitelisting (subnet/IP-based access rules)
- Resource tagging for governance

## Documentation

- **Wiki**: Publish `Wiki/` folder as Azure DevOps wiki
- **Bicep docs**: Auto-generated from inline comments using `Tools/Bicep/` scripts
- **Azure best practices**: See `Wiki/Azure.md` for general guidance

## Common Pitfalls

1. **Don't bypass Invoke-Executable**: Direct `az` calls won't fail pipelines correctly
2. **Always import AzDocs.Common**: Scripts fail without the module's helper functions
3. **Registry alias mismatch**: Update `bicepconfig.json` if ACR name changes
4. **Parameter validation**: Use `[Parameter(Mandatory)]` and validation attributes in PowerShell
5. **Case sensitivity**: Bicep imports are case-sensitive on Linux build agents
