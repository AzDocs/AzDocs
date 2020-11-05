[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $appServiceResourceGroupName,

    [Parameter(Mandatory)]
    [string] $appServiceName,

    [Parameter(Mandatory)]
    [string] $vnetName,

    [Parameter(Mandatory)]
    [string] $appServiceVnetIntegrationSubnetName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===


if ((invoke-Executable az webapp vnet-integration list --resource-group $appServiceResourceGroupName --name $appServiceName).length -le 2) {
    Write-Host "VNET Integration not found, adding it to $appServiceName"
    invoke-Executable az webapp vnet-integration add --resource-group $appServiceResourceGroupName --name $appServiceName --vnet $vnetName --subnet $appServiceVnetIntegrationSubnetName
    invoke-Executable az webapp restart --name $appServiceName --resource-group $appServiceResourceGroupName
}