[CmdletBinding()]
param (
    [Parameter()]
    [String] $storageResourceGroupName,

    [Parameter()]
    [String] $appServiceResourceGroupName,

    [Parameter()]
    [String] $appServiceName,

    [Parameter()]
    [String] $storageAccountName,

    [Parameter()]
    [String] $roleToAssign
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

# Fetch the WebApp Identity ID
$appIdentityId = Invoke-Executable az webapp identity show --name $appServiceName --resource-group $appServiceResourceGroupName --query=principalId
Write-Host "appIdentityId: $appIdentityId"

# Fetch the StorageAccount ID
$storageId = Invoke-Executable az storage account show --name $storageAccountName --resource-group $storageResourceGroupName --query=id
Write-Host "storageId: $storageId"

# Assign the appropriate role to the appservice
Invoke-Executable az role assignment create  --role $roleToAssign --assignee-object-id $appIdentityId --scope $storageId
