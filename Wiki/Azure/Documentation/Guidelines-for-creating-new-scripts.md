[[_TOC_]]

# Guidelines for creating new scripts

If you want to create new scripts and PR them into this repo, make sure to follow the [Azure CLI unless](/Azure/Documentation#azure-cli-unless) rule. We make use of creating [powershell advanced functions](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-7.1). A general advise is to take a look at other scripts and copy those and go from there.

The start of every script should look something like this:

```powershell
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FictionalParameter
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet
```

Note the `Write-Header` which outputs the parameters that were given to this script for easy debugging.

and the end should look something like this:

```powershell
Write-Footer -ScopedPSCmdlet $PSCmdlet
```

Make sure to not `return` your function before calling `Write-Footer`. Instead of using `return`, use `Write-Output`.

## Coding Convention

We use the `Allman` code formatting preset from VSCode. Also we disable the `openBraceOnSameLine` setting in powershell. In theory your VSCode should already do this for you, since we've checked in our [settings.json](../../../../.vscode/settings.json) to the repository.

Another thing we do, is wrap our CLI statements in the `Invoke-Executable` method. This allows us to get better logging for our CLI statements. Next to this it also allows us to set the `System.Debug` variable in our pipeline to `true`, which will enable debug mode for CLI as well (it appends `--debug` to all CLI statements). And the final, maybe most important, thing it does is act accordingly whenever an exitcode is returned by the CLI statements. In short: Vanilla CLI does not always break the pipeline when it should. For example: if you create a resource, and the CLI fails, your pipeline will still turn out to be green and continue the next steps. The `Invoke-Executable` wrapper makes sure it checks the output and breaks the pipeline whenever this is desired. There is also a flag (`-AllowToFail`) which disables this behaviour.

### Naming

- Our script & function parameters are written CamelCase
- Local variables are all lowercase
- Functionnames are written CamelCase
- Names should be logical, recognizable and should avoid confusion (see below).
- We try to follow the [Noun-verb](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1) naming for functions

We also make sure that there can be no confusion between parameters and the working of these parameters. This means that your parameters should explicitly be named for what it is. For example; in the `Create-Storage-account.ps1` script there are multiple parameters which are "names". To make sure we know exactly which value to put in which parameter, we've named all parameters as following: `StorageAccountName`, `StorageAccountResourceGroupName`, `ApplicationVnetResourceGroupName`, `ApplicationVnetName`, `ApplicationSubnetName` etc. We couldve named `StorageAccountName` simply: `Name` but this might've been confusing. So always be overly explicit with your parameter names.

### Code conventions checklist

Whenever submitting new scripts, please make sure it is checked against the checklist below.

- <input type="checkbox"> Using the `Allman` code formatting with `openBraceOnSameLine` set to false.
- <input type="checkbox"> All CLI statements are wrapped into `Invoke-Executable`.
- <input type="checkbox"> All scripts should be idempotent.
- <input type="checkbox"> For CLI statements use full parameter names instead of abbreviations. So `--name` instead of `-n` and `--resource-group` instead of `-g`.
- <input type="checkbox"> Be explicit with your script parameter names. As described in the previous paragraph.
- <input type="checkbox"> Scripts which are created should not break previous versions unless it's absolutely not possible to create backwards compatibility.
- <input type="checkbox"> Parameters for scripts that are mandatory, should be marked as such using the `[Parameter(Mandatory)]` notation.
- <input type="checkbox"> Use strongly typed parameters for all script parameters.
- <input type="checkbox"> Make sure to use validation on parameters when needed, e.g. `[Parameter(Mandatory)][ValidateSet('Basic', 'Standard', 'Premium')][string] $RedisInstanceSkuName`.
- <input type="checkbox"> ​Comments should be provided if needed to explain certain workings of the script.
- <input type="checkbox"> For every resource that can make use of Managed Identities, these should be created and used (see Create-Web-App-Linux.ps1).
- <input type="checkbox"> For every resource that can make use of Diagnostic Settings, these should be enabled and send to the correct LAW.
- <input type="checkbox"> For every resource that can make use of VNet whitelisting, this should be configurable and added to the script.
- <input type="checkbox"> For every resource that can make use of Private Endpoints, this should be configurable and added to the script.
- <input type="checkbox"> For every resource that can be created publicly, a switch statement should be added with the name 'ForcePublic' to allow this. If none of the private endpoint/vnet whitelisting parameters are provided and the switch is provided, the resource gets created, else the task will fail with an error.
- <input type="checkbox"> For every resource that has the possibility to set TLS, the TLS version should be checked if it is equal or higher than TLS 1.2. Make use of the `Assert-TLSVersion` function.
- <input type="checkbox"> For every resource that can be created without TLS enforced, a switch statement should be added with the name `ForceDisableTLS` to allow this. This so that this cannot happen unintentionally.
- <input type="checkbox"> A wiki page should be added with the following information:
  - <input type="checkbox"> Description - Short description of the script and what it does.
  - <input type="checkbox"> Parameters - A list of parameters that are used in the scripts, their descriptions, example values and if they're required.
  - <input type="checkbox"> YAML - A yaml task that can be copied/pasted into a pipeline.
  - <input type="checkbox"> Code - Link to download the script.
  - <input type="checkbox"> Links - Links that can be used to get more information about the different scripts.
- <input type="checkbox"> Make sure to also update the templates with newly created / updated yaml tasks.
- <input type="checkbox"> The script should've been tested (including for every subresource that it could be used for).
- <input type="checkbox"> When a script will be deprecated add a warning to the wiki page that the script will be deprecated.
- <input type="checkbox"> When a script will be deprecated add a warning with a message that the script is deprecated.
- <input type="checkbox"> When a script will be deprecated add a warning with the following so the task will complete with issues: `Write-Host "##vso[task.complete result=SucceededWithIssues;]"`
