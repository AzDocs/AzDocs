[[_TOC_]]

# Description
This snippet will add a public certificate to a app service.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| appServiceName | `myteamtestapi$(Release.EnvironmentName)` | The name of the app service. It's recommended to stick to lowercase alphanumeric characters. |
| appServiceResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the app service resides in |
| certificateNameForAppService | `MY Root CA` | The name which the certificate will have once it is uploaded in the app service (this doesn't have to be the same as the filename). A smart reference to the contents of the certificate is advised. |
| certificateFilePath | `$(my_pfx.secureFilePath)` | The path where the .cer file can be found. In a release to use the .cer you uploaded in "secure files" (Pipelines\Library), use the task "download a secure file". Set the certificatePath in the task output variables Reference name |

# Code
[Click here to download this script](../../../../src/App-Services/Add-Public-Certificate-to-App-Service.ps1)