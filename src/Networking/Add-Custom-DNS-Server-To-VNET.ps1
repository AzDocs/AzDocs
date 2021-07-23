[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VnetResourceGroupName,
    [Parameter(Mandatory)][string] $VnetName,
    [Parameter(Mandatory)][string] $DNSServers
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az network vnet update --resource-group $VnetResourceGroupName --name $VnetName --dns-servers $DNSServers

Write-Footer -ScopedPSCmdlet $PSCmdlet