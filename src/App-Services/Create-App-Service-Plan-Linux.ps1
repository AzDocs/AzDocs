[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $AppServicePlanSkuName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

# Create AppService Plan
$appServicePlanId = (Invoke-Executable az appservice plan create --is-linux --resource-group $AppServicePlanResourceGroupName  --name $AppServicePlanName --sku $AppServicePlanSkuName --tags ${ResourceTags} | ConvertFrom-Json).id

Write-Footer

Write-Output $appServicePlanId