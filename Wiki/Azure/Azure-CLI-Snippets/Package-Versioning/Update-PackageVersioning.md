[[_TOC_]]

# Description

This script will automatically update the versions for your packages. 

The versioning is based upon semver (https://semver.org/).

For NPM you will need to use the `npmAuthenticate` task to connect to your npm feed. 
For Nuget you will need to add a service connection to your nuget feed and add the `NuGetAuthenticate` task. 

When using this script in the build for your package and you have set `IsPreRelease` to `true`, this script will update the patch version and your result will be the following: 

For npm `[Major].[Minor].[Patch]` e.g. `1.1.2`. 
For nuget `[Major].[Minor].[Patch]-beta` e.g. `1.1.2-beta`.

When using this script in the build for your package and you have set `IsPreRelease` to `false`, this script will update the minor version and set the patch version to its default (0). Your result will be the following: 

For npm `[Major].[Minor].[Patch]` e.g. `1.2.0` 
For nuget `[Major].[Minor].[Patch]` e.g. `1.2.0`

When using this script in the build for your package and you have set `UpdateMajorVersion` to `true`, this script will update the major version and set the patch/minor version to its default (0). Your result will be the following: 

For npm `[Major].[Minor].[Patch]` e.g. `2.0.0`
For nuget `[Major].[Minor].[Patch]` e.g. `2.0.0`

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter              | Required                        | Example Value                                                                                | Description                                                                                                                |
| ---------------------- | ------------------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| PackageType            | <input type="checkbox">         | `nuget`/ `npm`                                                                               | The PackageType of the package you want to get the updated version of. Defaults to `nuget`.                                |
| PackageName            | <input type="checkbox" checked> | `my-package`                                                                                 | The PackageName of the package you want to get the updated version of.                                                     |
| NpmWorkingDirectory    | <input type="checkbox">         | `Frontend/package-name`                                                                      | This is the working directory where your package resides. This has to be set when working with the npmAuthenticate@0 task. |
| NugetSource            | <input type="checkbox">         | `https://pkgs.dev.azure.com/<organization> /_packaging/<artifact-feed> /nuget/v3/index.json` | The source of the nuget feed.                                                                                              |
| IsPreRelease           | <input type="checkbox">         | `$true`/`$false`                                                                             | If the package is a prerelease version. Defauls to `$true`.                                                                |
| UpdateMajorVersion     | <input type="checkbox">         | `$true`/`$false`                                                                             | If the major version needs to be updated. Defaults to `$false`.                                                            |
| OutputPipelineVariable | <input type="checkbox">         | `variable-name`                                                                              | The output pipeline variable the version needs to be put in.                                                               |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
      - task: PowerShell@2
        inputs:
          filePath: '$(Pipeline.Workspace)/AzDocs/Package-Versioning/Update-PackageVersioning.ps1'
          arguments: -PackageType '$(PackageType)' -PackageName '$(PackageName)' -NpmWorkingDirectory '$(NpmWorkingDir)' -NugetSource '$(NugetSource)' -IsPreRelease $(IsPreRelease) -UpdateMajorVersion $(UpdateMajorVersion) -OutputPipelineVariable "version"
          pwsh: true
```

# Code

[Click here to download this script](../../../../src/Package-Versioning/Update-PackageVersioning.ps1)

# Links
[Nuget Authenticate Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/package/nuget-authenticate?view=azure-devops)
[NPM Authenticate Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/package/npm-authenticate?view=azure-devops)