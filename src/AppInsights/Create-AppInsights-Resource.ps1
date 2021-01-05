[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $appInsightsName,

    [Parameter(Mandatory)]
    [string] $appInsightsResourceGroupName,

    [Parameter(Mandatory)]
    [string] $location
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

#az monitor app-insights is in preview. Need to add extension
Invoke-Executable az extension add --name application-insights

Invoke-Executable az monitor app-insights component create --app $appInsightsName --resource-group $appInsightsResourceGroupName --location $location

$id = (Invoke-Executable az resource show --resource-group $appInsightsResourceGroupName --name $appInsightsName --resource-type "Microsoft.Insights/components" | ConvertFrom-Json).properties.InstrumentationKey
#TODO Should this not be write-host and write-output with only the id?
Write-Output "The AppInsightsInstrumentationKey of the AppInsights workspace is $id"

Write-Footer