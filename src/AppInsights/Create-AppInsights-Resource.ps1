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
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

#az monitor app-insights is in preview. Need to add extension
Invoke-Executable az extension add --name application-insights

Invoke-Executable az monitor app-insights component create --app $appInsightsName --resource-group $appInsightsResourceGroupName --location $location

$id = (Invoke-Executable az resource show --resource-group $appInsightsResourceGroupName --name $appInsightsName --resource-type "Microsoft.Insights/components" | ConvertFrom-Json).properties.InstrumentationKey
Write-Output "The AppInsightsInstrumentationKey of the AppInsights workspace is $id"