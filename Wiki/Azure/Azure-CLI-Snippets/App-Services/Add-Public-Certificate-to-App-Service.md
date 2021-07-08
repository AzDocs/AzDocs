[[_TOC_]]

# Description

This snippet will add a public certificate to a app service.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceName | `myteamtestapi$(Release.EnvironmentName)` | The name of the app service. It's recommended to stick to lowercase alphanumeric characters. |
| AppServiceResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the app service resides in |
| AppServiceCertificateName | `MY Root CA` | The name which the certificate will have once it is uploaded in the app service (this doesn't have to be the same as the filename). A smart reference to the contents of the certificate is advised. |
| AppServiceCertificateFilePath | `$(my_pfx.secureFilePath)` | The path where the .cer file can be found. In a release, use the .cer you uploaded in (It's recommended to stick to lowercase alphanumeric characters when naming the .cer files in the portal) "secure files" (Pipelines\Library) and use the task "download a secure file". Set the certificatePath in the task output variables Reference name |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Add Public Certificate to App Service'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Services/Add-Public-Certificate-to-App-Service.ps1'
               arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceCertificateName '$(AppServiceCertificateName)' -AppServiceCertificateFilePath '$(AppServiceCertificateFilePath)'"
```

# Code

[Click here to download this script](../../../../src/App-Services/Add-Public-Certificate-to-App-Service.ps1)
