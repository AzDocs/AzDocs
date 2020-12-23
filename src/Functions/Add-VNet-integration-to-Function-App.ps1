[CmdletBinding()]
param (
    [Parameter()]
    [String] $functionAppResourceGroupName,

    [Parameter()]
    [string] $functionAppName,

    [Parameter()]
    [string] $vnetName,

    [Parameter()]
    [string] $functionAppVnetIntegrationSubnetName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

if((Invoke-Executable az functionapp vnet-integration list -g $functionAppResourceGroupName -n $functionAppName).length -le 2)
{
    Write-Host "VNET Integration not found, adding it to $functionAppName"
    Invoke-Executable az functionapp vnet-integration add --resource-group $functionAppResourceGroupName --name $functionAppName --vnet $vnetName --subnet $functionAppVnetIntegrationSubnetName
    Invoke-Executable az functionapp restart --name $functionAppName --resource-group $functionAppResourceGroupName
}

Write-Footer