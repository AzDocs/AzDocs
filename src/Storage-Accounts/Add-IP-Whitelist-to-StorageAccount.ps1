[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToWhitelist)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim()
}

Invoke-Executable az storage account network-rule add --account-name $StorageAccountName --resource-group $StorageAccountResourceGroupName --ip-address $CIDRToWhitelist

Write-Footer -ScopedPSCmdlet $PSCmdlet