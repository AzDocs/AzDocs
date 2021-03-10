[CmdletBinding()]
param (
    [Alias("LawResourceGroupName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceGroupName,
    [Alias("LawName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Alias("LawRetentionInDays")]
    [Parameter()][int] $LogAnalyticsWorkspaceRetentionInDays = 30,
    [Parameter()][switch] $PublicInterfaceIngestionEnabled,
    [Parameter()][switch] $PublicInterfaceQueryAccess,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter()][string[]] $LogAnalyticsWorkspaceSolutionTypes
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

#install required extensions
Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt
Invoke-Executable az extension add --name log-analytics-solution

$scriptArguments = "--workspace-name", "$LogAnalyticsWorkspaceName", "--resource-group", "$LogAnalyticsWorkspaceResourceGroupName", "--retention-time", "$LogAnalyticsWorkspaceRetentionInDays", "--tags", $ResourceTags

if ($PublicInterfaceIngestionEnabled)
{
    $scriptArguments += "--ingestion-access", "Enabled"
}
else
{
    $scriptArguments += "--ingestion-access", "Disabled"
}

if ($PublicInterfaceQueryAccess)
{
    $scriptArguments += "--query-access", "Enabled"
}
else
{
    $scriptArguments += "--query-access", "Disabled"
}

Invoke-Executable az monitor log-analytics workspace create @scriptArguments

if ($LogAnalyticsWorkspaceSolutionTypes)
{
    $logAnalyticsWorkspaceResourceId = (Invoke-Executable -AllowToFail az monitor log-analytics workspace show --workspace-name $LogAnalyticsWorkspaceName --resource-group $LogAnalyticsWorkspaceResourceGroupName.ToLower() | ConvertFrom-Json).Id
    if ($logAnalyticsWorkspaceResourceId)
    {
        foreach ($type in $LogAnalyticsWorkspaceSolutionTypes)
        {
            Write-Host "Adding the following solutiontype = $type to the log analytics workspace"
            Invoke-Executable az monitor log-analytics solution create --resource-group $LogAnalyticsWorkspaceResourceGroupName.ToLower() --solution-type $type  --workspace $logAnalyticsWorkspaceResourceId
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet