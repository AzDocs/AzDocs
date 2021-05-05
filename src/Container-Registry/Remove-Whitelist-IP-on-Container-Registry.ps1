[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter()][string] $CIDRToRemoveFromWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToRemoveFromWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim()
    $CIDRToRemoveFromWhitelist += '/32'
}

Invoke-Executable az acr network-rule remove --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName --ip-address $CIDRToRemoveFromWhitelist

Write-Footer -ScopedPSCmdlet $PSCmdlet