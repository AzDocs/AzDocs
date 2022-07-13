
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $CdnEndpointName,
    [Parameter(Mandatory)][string] $CdnProfileName,
    [Parameter(Mandatory)][string] $CdnResourceGroupName,
    [Parameter(Mandatory)][string] $Origin,
    [Parameter(Mandatory)][string] $OriginHostHeader,
    [Parameter()][ValidateSet("BypassCaching", "IgnoreQueryString", "NotSet", "UseQueryString" )] $QueryStringCaching = "UseQueryString"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az cdn endpoint create --name $CdnEndpointName --origin $Origin --profile-name $CdnProfileName --resource-group $CdnResourceGroupName --query-string-caching $QueryStringCaching --origin-host-header $OriginHostHeader

Write-Footer -ScopedPSCmdlet $PSCmdlet