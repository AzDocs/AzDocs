[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VnetResourceGroupName,
    [Parameter(Mandatory)][string] $VnetName,
    [Parameter(Mandatory)][string] $RemoteVnetResourceGroupName,
    [Parameter(Mandatory)][string] $RemoteVnetName,
    [Parameter(Mandatory)][string] $RemoteVnetSubscriptionId,
    [Parameter()][bool] $AllowForwardedTrafficToRemoteVnet = $true, 
    [Parameter()][bool] $AllowVnetAccessToRemoteVnet = $true,
    [Parameter(Mandatory)][string] $CurrentSubscriptionId
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetPeeringName = "$($VnetName)-$($RemoteVnetName)"
$remoteVnetId = "/subscriptions/$($RemoteVnetSubscriptionId)/resourceGroups/$($RemoteVnetResourceGroupName)/providers/Microsoft.Network/VirtualNetworks/$($RemoteVnetName)"

$optionalArguments = @()
if ($AllowForwardedTrafficToRemoteVnet)
{
    $optionalArguments += '--allow-forwarded-traffic'
}

if ($AllowVNetAccessToRemoteVnet)
{
    $optionalArguments += '--allow-vnet-access'
}

Invoke-Executable az network vnet peering create --name $vnetPeeringName --vnet-name $VnetName --resource-group $VnetResourceGroupName --remote-vnet $remoteVnetId --subscription $CurrentSubscriptionId @optionalArguments

Write-Footer -ScopedPSCmdlet $PSCmdlet