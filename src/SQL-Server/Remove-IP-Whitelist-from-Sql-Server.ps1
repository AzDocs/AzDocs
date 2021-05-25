[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
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

# Preparation
$sqlServerLowerCase = $SqlServerName.ToLower()
$ruleName = ($CIDRToRemoveFromWhitelist -replace "\.", "-") -replace "/", "-"

# Execute whitelist
Invoke-Executable az sql server firewall-rule delete --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name $ruleName

Write-Footer -ScopedPSCmdlet $PSCmdlet