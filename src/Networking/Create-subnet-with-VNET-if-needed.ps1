[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VnetResourceGroupName,
    [Parameter(Mandatory)][string] $VnetName,
    [Parameter(Mandatory)][string] $VnetCidr = '10.0.0.0/16',
    [Parameter(Mandatory)][string] $SubnetName,
    [Parameter(Mandatory)][string] $Subnet,
    [Parameter()][string] $DNSServers = '168.63.129.16', #Defaults to Azure Private Endpoint DNS
    [Parameter()][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if (!$(Invoke-Executable -AllowToFail az network vnet show --resource-group $VnetResourceGroupName --name $VnetName))
{
    Invoke-Executable az network vnet create --resource-group $VnetResourceGroupName --name $VnetName --dns-servers $DNSServers --address-prefixes $VnetCidr --tags @ResourceTags
}

if (!$(Invoke-Executable -AllowToFail az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName))
{
    Invoke-Executable az network vnet subnet create --resource-group $VnetResourceGroupName --vnet-name $VnetName --name $SubnetName --address-prefixes $Subnet
}

Write-Footer -ScopedPSCmdlet $PSCmdlet