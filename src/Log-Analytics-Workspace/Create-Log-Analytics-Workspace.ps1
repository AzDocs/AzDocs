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

Write-Host "Script Arguments: $scriptArguments"

az monitor log-analytics workspace create @scriptArguments