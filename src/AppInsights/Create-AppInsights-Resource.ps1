[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
    [Alias("Location")]
    [Parameter(Mandatory)][string] $AppInsightsLocation
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

#az monitor app-insights is in preview. Need to add extension
Invoke-Executable az extension add --name application-insights

Invoke-Executable az monitor app-insights component create --app $AppInsightsName --resource-group $AppInsightsResourceGroupName --location $AppInsightsLocation

$instrumentationKey = (Invoke-Executable az resource show --resource-group $AppInsightsResourceGroupName --name $AppInsightsName --resource-type "Microsoft.Insights/components" | ConvertFrom-Json).properties.InstrumentationKey

Write-Host "The AppInsightsInstrumentationKey of the AppInsights workspace is $instrumentationKey"
Write-Output $instrumentationKey

Write-Footer