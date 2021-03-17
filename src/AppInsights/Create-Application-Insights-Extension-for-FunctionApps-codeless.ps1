[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter()][string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Set the AppInsights connection information on the AppService
SetAppInsightsForFunctionApp -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -FunctionAppName $FunctionAppName -FunctionAppResourceGroupName $FunctionAppResourceGroupName -AppServiceSlotName $AppServiceSlotName

$additionalParameters = @()
if ($AppServiceSlotName) {
    $additionalParameters += '--slot' , $AppServiceSlotName
}

# Enable Codeless AppInsights module with optional settings. Note: this might affect performance due to heavy monitoring
Invoke-Executable az functionapp config appsettings set --name $FunctionAppName --resource-group $FunctionAppResourceGroupName @additionalParameters --settings "ApplicationInsightsAgent_EXTENSION_VERSION=~2" "InstrumentationEngine_EXTENSION_VERSION=~1" "XDT_MicrosoftApplicationInsights_BaseExtensions=~1" "XDT_MicrosoftApplicationInsights_Mode=recommended"

Write-Footer -ScopedPSCmdlet $PSCmdlet
