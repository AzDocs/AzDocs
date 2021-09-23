[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter()][string] $KeyvaultCertificatePermissions,
    [Parameter()][string] $KeyvaultKeyPermissions,
    [Parameter()][string] $KeyvaultSecretPermissions,
    [Parameter()][string] $KeyvaultStoragePermissions,
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots)
{
    $slots = (Invoke-Executable az webapp deployment slot list --resource-group $AppServiceResourceGroupName --name $AppServiceName | ConvertFrom-Json)
    foreach ($slot in $slots)
    {
        $identityId = Get-ManagedIdentity -AppService -ResourceName $AppServiceName -ResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $slot.name
        Set-KeyvaultPermissions -KeyvaultName $KeyvaultName -ManagedIdentityId $identityId -KeyvaultCertificatePermissions $KeyvaultCertificatePermissions -KeyvaultKeyPermissions $KeyvaultKeyPermissions -KeyvaultSecretPermissions $KeyvaultSecretPermissions -KeyvaultStoragePermissions $KeyvaultStoragePermissions
    }
}

$identityId = Get-ManagedIdentity -AppService -ResourceName $AppServiceName -ResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName:$AppServiceSlotName
Set-KeyvaultPermissions -KeyvaultName $KeyvaultName -ManagedIdentityId $identityId -KeyvaultCertificatePermissions $KeyvaultCertificatePermissions -KeyvaultKeyPermissions $KeyvaultKeyPermissions -KeyvaultSecretPermissions $KeyvaultSecretPermissions -KeyvaultStoragePermissions $KeyvaultStoragePermissions

Write-Footer -ScopedPSCmdlet $PSCmdlet