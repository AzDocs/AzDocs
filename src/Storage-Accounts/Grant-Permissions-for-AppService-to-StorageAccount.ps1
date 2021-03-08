[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $RoleToAssign
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch the WebApp Identity ID
$appIdentityId = Get-ManagedIdentity -AppService -ResourceName $AppServiceName -ResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $AppServiceSlotName

# Fetch the StorageAccount ID
$storageId = Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageResourceGroupName --query=id
Write-Host "storageId: $storageId"

# Assign the appropriate role to the appservice
Invoke-Executable az role assignment create --role $RoleToAssign --assignee-object-id $appIdentityId --scope $storageId

Write-Footer -ScopedPSCmdlet $PSCmdlet