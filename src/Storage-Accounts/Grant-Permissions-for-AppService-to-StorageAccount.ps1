[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $storageResourceGroupName,

    [Parameter(Mandatory)]
    [String] $appServiceResourceGroupName,

    [Parameter(Mandatory)]
    [String] $appServiceName,

    [Parameter()]
    [String] $AppServiceSlotName,

    [Parameter(Mandatory)]
    [String] $storageAccountName,

    [Parameter(Mandatory)]
    [String] $roleToAssign
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Get-ManagedIdentity.ps1"
#endregion ===END IMPORTS===

Write-Header

# Fetch the WebApp Identity ID
$appIdentityId = Get-ManagedIdentity -Name $appServiceName -ResourceGroup $appServiceResourceGroupName -SlotName $AppServiceSlotName

# Fetch the StorageAccount ID
$storageId = Invoke-Executable az storage account show --name $storageAccountName --resource-group $storageResourceGroupName --query=id
Write-Host "storageId: $storageId"

# Assign the appropriate role to the appservice
Invoke-Executable az role assignment create --role $roleToAssign --assignee-object-id $appIdentityId --scope $storageId

Write-Footer