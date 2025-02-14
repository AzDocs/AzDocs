[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
    [Alias('Location')]
    [Parameter(Mandatory)][string] $AppInsightsLocation, 
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,

    [Parameter()][System.Object[]] $ResourceTags,

    # Diagnostic settings
    [Parameter()][string] $DiagnosticSettingsLogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

#az monitor app-insights is in preview. Need to add extension
Invoke-Executable az extension add --name application-insights

# Create Application Insights
$applicationInsightsId = (Invoke-Executable az monitor app-insights component create --app $AppInsightsName --resource-group $AppInsightsResourceGroupName --location $AppInsightsLocation --workspace $LogAnalyticsWorkspaceResourceId | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $applicationInsightsId -ResourceTags ${ResourceTags}
}

# Add diagnostic settings to Application Insights
if ($DiagnosticSettingsLogAnalyticsWorkspaceResourceId)
{
    Set-DiagnosticSettings -ResourceId $applicationInsightsId -ResourceName $AppInsightsName -LogAnalyticsWorkspaceResourceId $DiagnosticSettingsLogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

$instrumentationKey = (Invoke-Executable az resource show --resource-group $AppInsightsResourceGroupName --name $AppInsightsName --resource-type 'Microsoft.Insights/components' | ConvertFrom-Json).properties.InstrumentationKey

Write-Host "The AppInsightsInstrumentationKey of the AppInsights workspace is $instrumentationKey"
Write-Output $instrumentationKey

Write-Footer -ScopedPSCmdlet $PSCmdlet