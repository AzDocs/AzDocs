[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $NatGatewayName,
    [Parameter(Mandatory)][string] $NatGatewayResouceGroupName,
    [Parameter()][string] $OutputPipelineVariableName = "NatGatewayIpAddress"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$publicIpId = (Invoke-Executable az network nat gateway show --resource-group $NatGatewayResouceGroupName --name $NatGatewayName | ConvertFrom-Json).publicIpAddresses.id
if ($publicIpId) {
    $ipAddress = (Invoke-Executable az network public-ip show --id $publicIpId | ConvertFrom-Json).ipAddress
    Write-Host "Found ipaddress: $ipAddress"
    Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$ipAddress"
}
else {
    Write-Host "No public ip found for NAT Gateway: $NatGatewayName"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet