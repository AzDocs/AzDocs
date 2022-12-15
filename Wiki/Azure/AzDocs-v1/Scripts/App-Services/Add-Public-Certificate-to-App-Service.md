[[_TOC_]]

# Description

This snippet will add a public certificate to a app service.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppServiceName | <input type="checkbox" checked> | `myteamtestapi$(Release.EnvironmentName)` | The name of the app service. It's recommended to stick to lowercase alphanumeric characters. |
| AppServiceResourceGroupName | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the app service resides in |
| AppServiceCertificateName | <input type="checkbox" checked> | `MY Root CA` | The name which the certificate will have once it is uploaded in the app service (this doesn't have to be the same as the filename). A smart reference to the contents of the certificate is advised. |
| AppServiceCertificateFilePath | <input type="checkbox" checked> | `$(my_pfx.secureFilePath)` | The path where the .cer file can be found. In a release, use the .cer you uploaded in (It's recommended to stick to lowercase alphanumeric characters when naming the .cer files in the portal) "secure files" (Pipelines\Library) and use the task "download a secure file". Set the certificatePath in the task output variables Reference name |
| AppServiceSlotName | <input type="checkbox"> | `staging` | The slot name of the appservice. |
| ApplyToAllSlots | <input type="checkbox"> | `$true` | To apply the certificate to all deployment slots associated with the appservice. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzurePowerShell@5
  displayName: "Add Public Certificate to App Service"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    ScriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Add-Public-Certificate-to-App-Service.ps1"
    ScriptArguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceCertificateName '$(AppServiceCertificateName)' -AppServiceCertificateFilePath '$(AppServiceCertificateFilePath)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
    FailOnStandardError: true
    azurePowerShellVersion: LatestVersion
    pwsh: true
```

# Code

[Click here to download this script](../../../../../src/App-Services/Add-Public-Certificate-to-App-Service.ps1)
