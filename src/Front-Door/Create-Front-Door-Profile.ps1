[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
    [Parameter(Mandatory)][string][ValidateSet('Premium_AzureFrontDoor', 'Standard_AzureFrontDoor')] $FrontDoorSku,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
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

$frontDoorId = (Invoke-Executable az afd profile create --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --sku $FrontDoorSku | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $frontDoorId -ResourceTags ${ResourceTags}
}

# Create diagnostics settings for the Front Door resource
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $frontDoorId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $FrontDoorProfileName
}
else
{
    Set-DiagnosticSettings -ResourceId $frontDoorId -ResourceName $FrontDoorProfileName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet