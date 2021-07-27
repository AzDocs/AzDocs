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

[] Using the `Allman` code formatting with `openBraceOnSameLine` set to false.
[] All CLI statements are wrapped into `Invoke-Executable`.

- For CLI statements use full parameter names instead of abbreviations. So `--name` instead of `-n` and `--resource-group` instead of `-g`.
- Be explicit with your script parameter names. As described in the previous paragraph.
- Scripts which are created should not break previous versions unless it's absolutely not possible to create backwards compatibility.
- Parameters for scripts that are mandatory, should be marked as such using the `[Parameter(Mandatory)]` notation.
- Use strongly typed parameters for all script parameters.
- ​Comments should be provided if needed to explain certain workings of the script.
- For every resource that can make use of Managed Identities, these should be created and used (see Create-Web-App-Linux.ps1).
- For every resource that can make use of Diagnostic Settings, these should be enabled and send to the correct LAW.
- For every resource that can make use of VNet whitelisting, this should be configurable and added to the script.
- For every resource that can make use of Private Endpoints, this should be configurable and added to the script.
- A wiki page should be added with the following information:
  - Description - Short description of the script and what it does.
  - Parameters - A list of parameters that are used in the scripts, their descriptions, example values and if they're required.
  - YAML - A yaml task that can be copied/pasted into a pipeline.
  - Code - Link to download the script.
  - Links - Links that can be used to get more information about the different scripts.
- The script should've been tested (including for every subresource that it could be used for).
