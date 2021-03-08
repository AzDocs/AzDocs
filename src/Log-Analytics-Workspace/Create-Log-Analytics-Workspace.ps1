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
    [Parameter(Mandatory)][System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$scriptArguments = "--workspace-name","$LogAnalyticsWorkspaceName", "--resource-group","$LogAnalyticsWorkspaceResourceGroupName", "--retention-time","$LogAnalyticsWorkspaceRetentionInDays", "--tags",$ResourceTags

if ($PublicInterfaceIngestionEnabled) {
    $scriptArguments += "--ingestion-access","Enabled"
} else {
    $scriptArguments += "--ingestion-access","Disabled"
}

if ($PublicInterfaceQueryAccess) {
    $scriptArguments += "--query-access","Enabled"
} else {
    $scriptArguments += "--query-access","Disabled"
}

Invoke-Executable az monitor log-analytics workspace create @scriptArguments

Write-Footer -ScopedPSCmdlet $PSCmdlet