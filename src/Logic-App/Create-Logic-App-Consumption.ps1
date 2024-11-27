[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $LogicAppResourceGroupName,
    [Parameter(Mandatory)][string] $LogicAppName,
    [Parameter(Mandatory)][string] $LogicAppDefinitionPath,
    [Parameter()][string] $LogicAppLocation = 'westeurope',
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $ResourceTags,

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

Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt
$logicAppId = (Invoke-Executable az logic workflow create --resource-group $LogicAppResourceGroupName --location $LogicAppLocation --name $LogicAppName --definition $LogicAppDefinitionPath | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $logicAppId -ResourceTags ${ResourceTags}
}

#  Create diagnostics settings
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $logicAppId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $LogicAppName
}
else
{
    Set-DiagnosticSettings -ResourceId $logicAppId -ResourceName $LogicAppName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet