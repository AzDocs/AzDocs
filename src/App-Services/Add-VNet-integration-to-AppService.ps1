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
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$fullAppServiceName = $appServiceName
$additionalParameters = @()

if ($AppServiceSlotName) {
    $additionalParameters += '--slot' , $AppServiceSlotName
    $fullAppServiceName += " [$AppServiceSlotName]"
}

$data = az webapp vnet-integration list --resource-group $appServiceResourceGroupName --name $appServiceName @additionalParameters | ConvertFrom-Json

if ($data) {
    Write-Host "VNET Integration found for $fullAppServiceName"
}
else {
    Write-Host "VNET Integration NOT found, adding it to $fullAppServiceName"
    invoke-Executable az webapp vnet-integration add --resource-group $appServiceResourceGroupName --name $appServiceName --vnet $vnetName --subnet $appServiceVnetIntegrationSubnetName @additionalParameters
    invoke-Executable az webapp restart --name $appServiceName --resource-group $appServiceResourceGroupName @additionalParameters
}
