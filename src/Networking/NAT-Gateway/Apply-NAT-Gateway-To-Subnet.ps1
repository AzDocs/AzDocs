[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $VnetName,
    [Parameter(Mandatory)][string] $VnetResourceGroupName,
    [Parameter(Mandatory)][string] $SubnetName,
    [Parameter(Mandatory)][string] $NatGatewayName,
    [Parameter(Mandatory)][string] $NatGatewayResouceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Prepare some information
$subnetId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
Write-Host "Subnet ID: $subnetId"

# Fetch the NAT Gateway ID
$natGatewayId = (Invoke-Executable az network nat gateway show --resource-group $NatGatewayResouceGroupName --name $NatGatewayName | ConvertFrom-Json).id

Invoke-Executable az network vnet subnet update --ids $subnetId --nat-gateway $natGatewayId

Write-Footer -ScopedPSCmdlet $PSCmdlet