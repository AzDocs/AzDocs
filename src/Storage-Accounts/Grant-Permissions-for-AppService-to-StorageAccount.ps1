[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $RoleToAssign,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

function GrantPermissions
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $StorageResourceGroupName,
        [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
        [Parameter(Mandatory)][string] $AppServiceName,
        [Parameter(Mandatory)][string] $StorageAccountName,
        [Parameter(Mandatory)][string] $RoleToAssign,
        [Parameter()][string] $AppServiceSlotName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Fetch the WebApp Identity ID
    $appIdentityId = Get-ManagedIdentity -AppService -ResourceName $AppServiceName -ResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $AppServiceSlotName

    # Fetch the StorageAccount ID
    $storageId = Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageResourceGroupName --query=id
    Write-Host "storageId: $storageId"

    # Assign the appropriate role to the appservice
    Invoke-Executable az role assignment create --role $RoleToAssign --assignee-object-id $appIdentityId --scope $storageId
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

# Fetch available slots if we want to deploy all slots
if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

# Grant permissions on the main given slot (normally production)
GrantPermissions -StorageResourceGroupName $StorageResourceGroupName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -StorageAccountName $StorageAccountName -RoleToAssign $RoleToAssign -AppServiceSlotName $AppServiceSlotName

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    GrantPermissions -StorageResourceGroupName $StorageResourceGroupName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -StorageAccountName $StorageAccountName -RoleToAssign $RoleToAssign -AppServiceSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet