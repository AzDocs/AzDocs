[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist
)

# TODO: FIX

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if (!$CIDRToRemoveFromWhitelist)
{
    $response = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
}

Invoke-Executable az acr network-rule remove --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName --ip-address $CIDRToRemoveFromWhitelist

Write-Footer -ScopedPSCmdlet $PSCmdlet