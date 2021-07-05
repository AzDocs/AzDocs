[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VnetResourceGroupName,
    [Parameter(Mandatory)][string] $VnetName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$ddosProtectionName = "$($VnetName)-ddosprot"

Invoke-Executable az network ddos-protection create --resource-group $VnetResourceGroupName --name $ddosProtectionName --vnets $VnetName

Invoke-Executable az network vnet update --resource-group $VnetResourceGroupName --name $VnetName --ddos-protection true --ddos-protection-plan $ddosProtectionName

Write-Footer -ScopedPSCmdlet $PSCmdlet