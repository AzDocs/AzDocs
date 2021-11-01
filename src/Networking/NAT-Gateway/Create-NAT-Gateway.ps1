[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $NatGatewayName,
    [Parameter(Mandatory)][string] $NatGatewayResouceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Make sure we have the Public IP Available
$publicIpName = "$($NatGatewayName)-nat-publicip"
$publicIpId = (Invoke-Executable -AllowToFail az network public-ip show --resource-group $NatGatewayResouceGroupName --name $publicIpName | ConvertFrom-Json).id
if (!$publicIpId)
{
    $publicIpId = (Invoke-Executable az network public-ip create --resource-group $NatGatewayResouceGroupName --name $publicIpName --sku Standard | ConvertFrom-Json).publicIp.id
}
Write-Host "Public IP ID: $publicIpId"

# Create the NAT Gateway
$natGatewayId = (Invoke-Executable -AllowToFail az network nat gateway show --resource-group $NatGatewayResouceGroupName --name $NatGatewayName | ConvertFrom-Json).id
if (!$natGatewayId)
{
    $natGatewayId = (Invoke-Executable az network nat gateway create --resource-group $NatGatewayResouceGroupName --name $NatGatewayName --public-ip-addresses $publicIpId | ConvertFrom-Json).vnetGateway.id
}

Write-Footer -ScopedPSCmdlet $PSCmdlet