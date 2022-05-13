[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SignalrName,
    [Parameter(Mandatory)][string] $SignalrResourceGroup,
    [Parameter(Mandatory)][ValidateSet('Standard_S1', 'Premium_P1')][string] $SignalrSku, 
    [Parameter()][ValidateSet('Classic', 'Default', 'Serverless')][string] $SignalrServiceMode = 'Serverless',
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][string] $SignalrAllowedOrigins, #TODO space separated - if empty allow * 
    [Parameter()][string] $SignalrUnitCount,
    [Parameter()][string[]] $ResourceTags,
    
    # Diagnostic settings
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParams = @()
if($SignalrUnitCount){
    $optionalParams += '--unit-count', $SignalrUnitCount
}

if($SignalrAllowedOrigins){
    $optionalParams += '--allowed-origins', $SignalrAllowedOrigins
}

$signalrId = (Invoke-Executable az signalr create --name $SignalrName --resource-group $SignalrResourceGroup --sku $SignalrSku --service-mode $SignalrServiceMode @optionalParams | ConvertFrom-Json).id

# Add managed identity
Invoke-Executable az signalr identity assign --identity '[system]' --name $SignalrName --resource-group $SignalrResourceGroup

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $signalrId -ResourceTags ${ResourceTags}
}

# Create diagnostics settings for the Front Door resource
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $signalrId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $SignalrName
}
else
{
    Set-DiagnosticSettings -ResourceId $signalrId -ResourceName $SignalrName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}


Write-Footer -ScopedPSCmdlet $PSCmdlet