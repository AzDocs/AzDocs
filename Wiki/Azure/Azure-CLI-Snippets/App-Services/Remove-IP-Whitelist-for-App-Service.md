[[_TOC_]]

# Description
This snippet will remove an IP range from the whitelist so that the website or SCM-part of the website cannot be accessed by the given ip range. Please note that does not work if the website has a private endpoint. So this should not work for a regular website that is bound to the compliancy rules.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceName | `App-Service-name` | Name of the app service to set the whitelist on. | 
| RuleName| `Hosted Agent` | Name of the Rule to remove from the whitelist/blacklist  |


# Code
[Click here to download this script](../../../../src/App-Services/Remove-Ip-Whitelist-For-App_service.ps1)