
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $CdnEndpointName,
    [Parameter(Mandatory)][string] $CdnProfileName,
    [Parameter(Mandatory)][string] $CdnResourceGroupName,
    [Parameter(Mandatory)][string] $ActionName,
    [Parameter()][string] $CacheDuration = '01:00:00',
    [Parameter()][ValidateSet('BypassCache', 'Override', 'SetIfMissing')] $CacheBehavior = 'Override',
    [Parameter()][int] $Order = 0 # order 0 is for global
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az cdn endpoint rule add --cache-behavior $CacheBehavior --action-name $ActionName --order $Order --cache-duration $CacheDuration --resource-group $CdnResourceGroupName --name $CdnEndpointName --profile-name $CdnProfileName  

Write-Footer -ScopedPSCmdlet $PSCmdlet