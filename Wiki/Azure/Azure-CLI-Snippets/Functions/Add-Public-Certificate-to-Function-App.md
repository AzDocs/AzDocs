[[_TOC_]]

# Description
This snippet will add a public certificate to a function app.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| functionAppName | `myteamtestapi$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters. |
| functionAppResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the function app resides in
| certificateNameForFunctionApp | `My Root CA` | The name which the certificate will have once it is uploaded in the function app (this doesn't have to be the same as the filename). A smart reference to the contents of the certificate is advised. |
| certificateFilePath | `$(my_pfx.secureFilePath)` | The path where the .cer file can be found. In a release to use the .cer you uploaded in "secure files" (Pipelines\Library), use the task "download a secure file". Set the certificatePath in the task output variables Reference name |

# Code
[Click here to download this script](../../../../src/Functions/Add-Public-Certificate-to-Function-App.ps1)