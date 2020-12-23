[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $LawResourceGroupName,

    [Parameter(Mandatory)]
    [String] $LawName,

    [Parameter(Mandatory)]
    [int] $LawRetentionInDays = 30,

    [Parameter()]
    [switch]
    $PublicInterfaceIngestionEnabled,

    [Parameter()]
    [switch]
    $PublicInterfaceQueryAccess,

    [Parameter(Mandatory)]
    [System.Object[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

$scriptArguments = "--workspace-name","$LawName", "--resource-group","$LawResourceGroupName", "--retention-time","$LawRetentionInDays", "--tags",$ResourceTags

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

Write-Footer