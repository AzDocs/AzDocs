[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $FunctionAppVnetIntegrationName,
    [Parameter(Mandatory)][string] $FunctionAppVnetIntegrationSubnetName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

if((Invoke-Executable az functionapp vnet-integration list --resource-group $FunctionAppResourceGroupName --name $FunctionAppName).length -le 2)
{
    Write-Host "VNET Integration not found, adding it to $FunctionAppName"
    Invoke-Executable az functionapp vnet-integration add --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --vnet $FunctionAppVnetIntegrationName --subnet $FunctionAppVnetIntegrationSubnetName
    Invoke-Executable az functionapp restart --name $FunctionAppName --resource-group $FunctionAppResourceGroupName
}

# Set WEBSITE_VNET_ROUTE_ALL=1 for vnet integration
Invoke-Executable az functionapp config appsettings set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --settings "WEBSITE_VNET_ROUTE_ALL=1"

Write-Footer