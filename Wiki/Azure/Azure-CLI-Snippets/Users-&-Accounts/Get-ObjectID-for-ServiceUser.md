[[_TOC_]]

# Description
This snippet will give you the ObjectID for a Service User. This objectid is needed in the [Grant AppService dataread&write&ddladmin rights on SQL Server](/Azure/Azure-CLI-Snippets/SQL-Server/Grant-AppService-dataread&write&ddladmin-rights-on-SQL-Server) step for example.

NOTE: THIS IS CANNOT BE A SERVICE PRINCIPAL USER but should be a AD User which can be requested @ Workspaces team.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| serviceUserEmail | `my_user@domain.com` | The e-mailaddress for the service user |
| serviceUserPassword | `ThisIsMyC00LP@ssw0rd123!` | The password for the service user |


# Code
[Click here to download this script](../../../../src/Users-and-Accounts/Get-ObjectID-for-ServiceUser.ps1)

# Links

[Azure CLI - az-login](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login)

[Azure CLI - az-ad-user-show](https://docs.microsoft.com/en-us/cli/azure/ad/user?view=azure-cli-latest#az-ad-user-show)
