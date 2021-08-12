[[_TOC_]]

# Description

This snippet will add a public certificate to a function app.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppName | `myteamtestapi$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters. |
| FunctionAppResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the function app resides in
| FunctionAppCertificateName | `My Root CA` | The name which the certificate will have once it is uploaded in the function app (this doesn't have to be the same as the filename). A smart reference to the contents of the certificate is advised. |
| FunctionAppCertificateFilePath | `$(my_pfx.secureFilePath)` |The path where the .cer file can be found. In a release, use the .cer you uploaded in (It's recommended to stick to lowercase alphanumeric characters when naming the .cer files in the portal) "secure files" (Pipelines\Library) and use the task "download a secure file". Set the certificatePath in the task output variables Reference name |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzurePowerShell@5
  displayName: "Add Public Certificate to Function App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    ScriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Add-Public-Certificate-to-Function-App.ps1"
    ScriptArguments: "-FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppCertificateName '$(FunctionAppCertificateName)' -FunctionAppCertificateFilePath '$(FunctionAppCertificateFilePath)'"
    FailOnStandardError: true
    azurePowerShellVersion: LatestVersion
    pwsh: true
```

# Code

[Click here to download this script](../../../../src/Functions/Add-Public-Certificate-to-Function-App.ps1)
