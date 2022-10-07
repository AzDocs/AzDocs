[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $NatGatewayName,
    [Parameter(Mandatory)][string] $NatGatewayResouceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$publicIpId = (Invoke-Executable az network nat gateway show --resource-group $NatGatewayResouceGroupName --name $NatGatewayName | ConvertFrom-Json).publicIpAddresses.id
if ($publicIpId) {
    Invoke-Executable az network public-ip show --resource-group $NatGatewayResourceGroupName --na
}

Write-Footer -ScopedPSCmdlet $PSCmdlet