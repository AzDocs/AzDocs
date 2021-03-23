[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppInsightsName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
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
        [Parameter(Mandatory)][string] $AppServiceName,
        [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
        [Parameter(Mandatory)][string] $AppInsightsResourceGroupName,
        [Parameter()][string] $AppServiceSlotName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Set the AppInsights connection information on the AppService
    SetAppInsightsForAppService -AppInsightsName $AppInsightsName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -AppServiceName $AppServiceName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceSlotName $AppServiceSlotName

    $additionalParameters = @()
    if ($AppServiceSlotName) {
        $additionalParameters += '--slot' , $AppServiceSlotName
    }

    # Enable Codeless AppInsights module with optional settings. Note: this might affect performance due to heavy monitoring
    Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters --settings "ApplicationInsightsAgent_EXTENSION_VERSION=~2" "InstrumentationEngine_EXTENSION_VERSION=~1" "XDT_MicrosoftApplicationInsights_BaseExtensions=~1" "XDT_MicrosoftApplicationInsights_Mode=recommended"
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

# Setup AppInsights for the given deployment slot (or default production slot)
SetupAppInsights -AppInsightsName $AppInsightsName -AppServiceName $AppServiceName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -AppServiceSlotName $AppServiceSlotName

# Apply to all slots if desired
foreach($availableSlot in $availableSlots)
{
    SetupAppInsights -AppInsightsName $AppInsightsName -AppServiceName $AppServiceName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppInsightsResourceGroupName $AppInsightsResourceGroupName -AppServiceSlotName $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet
