[[_TOC_]]

# Guidelines for creating new modules

If you want to create new modules, make sure they follow the [Code conventions checklist](#code-conventions-checklist) & [Naming convention](#naming). A general advise is to take a look at other scripts and copy those and go from there.

> **Copy an existing module before following this page.** This page describes intent; the 223 modules in `src-bicep/` describe practice. Several rules below were written as proposals and never became practice, and they are marked where that is the case. Before following any rule here, check whether the code agrees:
>
> ```bash
> grep -rl 'theParameterName' src-bicep --include=*.bicep | wc -l
> ```
>
> A rule no module follows is a proposal. `AGENTS.md` in the repository root carries the measured counts and is the contract agents work from.

Modules documentation is created based on the metadata you provide in modules.

It uses the [decorators](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameters#decorators) on the param and output sections. At the time of writing there is no proper solution for module documentation([See also this github issue](https://github.com/Azure/bicep/issues/7298)). We choose to use the same syntax as [powershell based help comments](  
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help). With the difference that powershell comment block uses `<# #>` tags and bicep uses the `/* */` tags.

## Coding Convention

Every Bicep module is built with the following 4 components (ordered as they should be ordered in your scripts):

- param
- var
- resource & (optional) module
- output

Each param should have a "high security standard" and/or "high quality of life" default value.
TODO: explain what this means.

### Naming convention

- params, vars, resources, modules & outputs are always written in camelCasing.

- Our script & function parameters are written PascalCase
- Names should be logical, recognizable and should avoid confusion (see below).

We also make sure that there can be no confusion between parameters and the working of these parameters. This means that your parameters should explicitly be named for what it is. For example; in the `blobServices.bicep` module there are multiple parameters which are "names". To make sure we know exactly which value to put in which parameter, we've named all parameters as following: `blobContainerName` & `storageAccountName` etc. We couldve named `blobContainerName` simply: `name` but this might've been confusing. So always be overly explicit with your parameter names.

### Code conventions checklist

Whenever submitting new modules or changing existing modules, please make sure it is checked against the checklist below.

- <input type="checkbox"> ~~Update the CHANGELOG with the changes you make.~~ **Not practice.** `Wiki/Azure/CHANGELOG.md` was last updated in May 2023 and documents v1 PowerShell scripts; no v2 module has ever updated it. Describe the change in the pull request instead.
- <input type="checkbox"> Using the VSCode Bicep module to format & verify the module. Run `az bicep build --file <module>` before committing: it catches a property that does not exist in the API version you pinned, reported as `BCP037`.
- <input type="checkbox"> Single purpose modules. So no creating storage account & blob container in one. Do include things like networking & security like vnet whitelisting into the creation of resources. **Exception:** create a child alongside its parent when the parent does not function without it. An Azure Managed Redis cluster does not serve traffic until its `databases` child exists, so `cache/redisenterprise` creates both. That is still one purpose.
- <input type="checkbox"> **Ship a standalone submodule for a child resource a caller may need to add on its own.** Put it in a folder named after the parent: `Cache/redis.bicep` has `Cache/redis/accessPolicyAssignments.bicep`. The submodule takes the parent name, fetches it with `existing`, and attaches the child. Without it a consuming repository must declare the child resource inline, which is what this library exists to prevent.
- <input type="checkbox"> **Verify the API version against the provider before pinning it**, with `az provider show -n <Namespace> --query "resourceTypes[?resourceType=='<type>'].apiVersions[]" -o tsv`. The Bicep types shipped with the CLI can lag or lead what the tenant accepts. Prefer a stable version over a preview one.
- <input type="checkbox"> Be explicit with your module parameter names. As described in the previous paragraph. So `storageAccountName` instead of `name` to avoid confusion.
- <input type="checkbox"> Modules which are modified should not break previous versions unless it's absolutely not possible to create backwards compatibility.
- <input type="checkbox"> Parameters are automatically set to required if there is no default value applied. _TODO metadata override required_
- <input type="checkbox"> Make sure to use validation [decorators](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameters#decorators) on parameters when needed & possible. For example: `@minLength`, `@maxLength` and `@allowed()`.
- <input type="checkbox"> ​Naming conventions should be implementable from the projectlayer. So no hardcoded names in the modules. For a configurable (sub)resourcename example; please look at the `ezApplicationGatewayEntrypointsBackendAddressPoolName` parameter in the `applicationGateways.bicep` module.
- <input type="checkbox"> For every resource that can make use of System Assigned Managed Identities, these should be created and used by default. Also support for User Assigned Managed Identities should be present. For an example; please look at the `identity` param in the `applicationGateways.bicep` module.
- <input type="checkbox"> For every resource that can make use of Diagnostic Settings, you should be able to pass a Log Analytics Workspace Resource ID to the module so that it will configure to log to that LAW. The pattern is a `logAnalyticsWorkspaceResourceId string?` parameter with the diagnostic settings resource guarded by `if (!empty(logAnalyticsWorkspaceResourceId))` (28 modules). There is no `diagnosticSettingsEnabled` parameter anywhere, despite what other pages claim.
- <input type="checkbox"> For every resource that has support for Tags, this should be configurable and added to the module.
- <input type="checkbox"> For every resource that has support for VNet whitelisting, this should be configurable and added to the module.
- <input type="checkbox"> For every resource that supports Private Endpoints, the module must support being paired with one. Private connectivity is the default posture, not an option the caller enables. **How this works is often misread:** the module does not build the endpoint. Exactly one module declares `Microsoft.Network/privateEndpoints`, and that is `Network/privateEndpoints.bicep` itself; every other module leaves the endpoint to the caller, who deploys the resource module and the private endpoint module side by side and wires them with `targetResourceId`. So do not add a `disablePrivateEndpoint` parameter, which exists in no module. Instead:
  - <input type="checkbox"> Default `publicNetworkAccess` to `Disabled`, so a caller who forgets the endpoint gets an unreachable resource rather than a public one.
  - <input type="checkbox"> Output the resource id, because the private endpoint module needs it as `targetResourceId`.
  - <input type="checkbox"> Document the private endpoint subresource (group id) in `.EXAMPLE` or `.LINKS` when it is not obvious. It is not always the resource name: `Microsoft.Cache/redis` uses `redisCache` while `Microsoft.Cache/redisEnterprise` uses `redisEnterprise`, and the wrong one fails at runtime rather than at deploy time.
  - VNet injection through a `subnetId` parameter is a different mechanism and does belong to the resource (4 modules).
- <input type="checkbox"> ~~a switch statement should be added with the name `forcePublic`~~ **Not practice.** No module has a `forcePublic` parameter; 24 use `publicNetworkAccess` with `@allowed(['Enabled','Disabled'])` defaulting to `Disabled`. Use that. The intent is unchanged: public traffic is blocked unless the caller opts in.
- <input type="checkbox"> For every resource that has the possibility to set TLS, the TLS version should be default on a secure TLS version (at the time of writing TLS 1.2 or higher).
- <input type="checkbox"> For every resource that can be created without TLS enforced, a switch statement should be added with the name `forceDisableTLS` to allow this. This so that this cannot happen unintentionally.
- <input type="checkbox"> Metadata should be added accordingly which is used to generate a wiki page for the bicep module. This metadata has to have the following information:
  - <input type="checkbox"> Description - Short description of the module and what it does.
  - <input type="checkbox"> Example - A bicep module call task that can be copied/pasted into your main bicep file.
  - <input type="checkbox"> Links - Links that can be used to get more information about the different resources.
- <input type="checkbox"> Make sure to also update the templates with newly created / updated yaml tasks.
- <input type="checkbox"> The script should've been tested (including for every subresource that it could be used for).
- <input type="checkbox"> When a script will be deprecated add a warning to the wiki page that the script will be deprecated.
- <input type="checkbox"> When a script will be deprecated, note it in the pull request and on its wiki page.

## Publishing your module

`pipelines/Acr/pipeline-bicep2acr.yml` publishes every `.bicep` file under `src-bicep/` as its own ACR artifact.

The **path becomes the module name**, lowercased, with `/` separators. `src-bicep/Cache/redisEnterprise.bicep` publishes as `cache/redisenterprise`, and `src-bicep/Cache/redisEnterprise/accessPolicyAssignments.bicep` as `cache/redisenterprise/accesspolicyassignments`.

The **build number is the tag**: `{yyyy.MM.dd}{.r}-{Build.SourceBranchName}`. Runs on `main` also publish `latest`.

**Branches publish too.** Run the pipeline on your feature branch and you get a real, consumable tag, so a consuming repository can integrate against your module before it merges. A branch named `feature/managed-redis-module` produces `2026.09.14.1-managed-redis-module`, because `Build.SourceBranchName` is the last path segment of the branch. Wait for the run to finish before referencing the tag: until it completes the artifact does not exist and the consumer fails with `BCP192: The artifact does not exist in the registry`.

## Generating the wiki page

`Tools/Bicep/Get-BicepMetadata.ps1` and `Tools/Bicep/Update-MetadataMarkdown.ps1` generate `Wiki/Azure/AzDocs-v2/Modules/` from the modules, so you do not write the page by hand.

**Pass absolute paths to both, and give `-Path` a directory, not a single file.** `Get-BicepMetadata` does a `Set-Location` to `-Path` and does not restore it, so a relative `-DestinationPath` resolves against the new location and the output lands somewhere else. `Update-MetadataMarkdown` deletes the target tree before writing, so a failed write leaves the wiki deleted rather than unchanged. One wrong invocation removed 221 pages.

```powershell
. .\Tools\Bicep\Get-BicepMetadata.ps1
. .\Tools\Bicep\Update-MetadataMarkdown.ps1
$metadata = Get-BicepMetadata -Path 'C:\full\path\to\src-bicep'
Update-MetadataMarkdown -Metadata $metadata -DestinationPath 'C:\full\path\to\Wiki\Azure\AzDocs-v2\Modules'
```

Run it over the whole tree and commit only the pages your change touched; regenerating produces no diff for modules you did not edit. Check `git status` before staging.
