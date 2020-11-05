[CmdletBinding()]
param (
    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $subnetName,

    [Parameter()]
    [String] $subnet,

    [Parameter()]
    [String] $DNSServers = "168.63.129.16", #Defaults to Azure Private Endpoint DNS

    [Parameter()]
    [System.Object[]] $resourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

if([String]::IsNullOrWhiteSpace($(az network vnet show -g $vnetResourceGroupName -n $vnetName)))
{
    Invoke-Executable az network vnet create -g $vnetResourceGroupName -n $vnetName --dns-servers $DNSServers --tags ${resourceTags}
}

if([String]::IsNullOrWhiteSpace($(az network vnet subnet show -g $vnetResourceGroupName -n $subnetName --vnet-name $vnetName)))
{
    Invoke-Executable az network vnet subnet create -g $vnetResourceGroupName --vnet-name $vnetName -n $subnetName --address-prefixes $subnet
}