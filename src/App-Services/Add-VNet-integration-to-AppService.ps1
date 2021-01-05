[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $appServiceResourceGroupName,

    [Parameter(Mandatory)]
    [string] $appServiceName,

    [Parameter(Mandatory)]
    [string] $vnetName,

    [Parameter(Mandatory)]
    [string] $appServiceVnetIntegrationSubnetName,

    [Parameter()]
    [string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

$fullAppServiceName = $appServiceName
$additionalParameters = @()

if ($AppServiceSlotName) {
    $additionalParameters += '--slot' , $AppServiceSlotName
    $fullAppServiceName += " [$AppServiceSlotName]"
}

$vnetIntegrations = Invoke-Executable az webapp vnet-integration list --resource-group $appServiceResourceGroupName --name $appServiceName @additionalParameters | ConvertFrom-Json
$matchedIntegrations = $vnetIntegrations | Where-Object  vnetResourceId -like "*/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$appServiceVnetIntegrationSubnetName"
if ($matchedIntegrations) {
    Write-Host "VNET Integration found for $fullAppServiceName"
}
else {
    Write-Host "VNET Integration NOT found, adding it to $fullAppServiceName"
    Invoke-Executable az webapp vnet-integration add --resource-group $appServiceResourceGroupName --name $appServiceName --vnet $vnetName --subnet $appServiceVnetIntegrationSubnetName @additionalParameters
    Invoke-Executable az webapp restart --name $appServiceName --resource-group $appServiceResourceGroupName @additionalParameters
}

Write-Footer