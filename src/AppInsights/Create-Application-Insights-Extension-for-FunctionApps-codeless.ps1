[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

function SetupAppInsights()
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $AppInsightsName,
        [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
        [Parameter(Mandatory)][string] $FunctionAppName,
        [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
        [Parameter()][string] $AppServiceSlotName
    )
    
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
}

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

# Setup AppInsights for the given deployment slot (or default production slot)
SetupAppInsights -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -FunctionAppName $FunctionAppName -FunctionAppResourceGroupName $FunctionAppResourceGroupName -AppServiceSlotName $AppServiceSlotName

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    SetupAppInsights -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -FunctionAppName $FunctionAppName -FunctionAppResourceGroupName $FunctionAppResourceGroupName -AppServiceSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet
