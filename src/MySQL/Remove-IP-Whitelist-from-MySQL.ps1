[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MySqlServerName,
    [Parameter(Mandatory)][string] $MySqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if(!$CIDRToRemoveFromWhitelist -and !$AccessRuleName)
{
    $response  = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
}

if(!$AccessRuleName)
{
    $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToRemoveFromWhitelist
    $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToRemoveFromWhitelist
    $firewallRules = Invoke-Executable az mysql server firewall-rule list --resource-group $MySqlServerResourceGroupName --server-name $MySqlServerName | ConvertFrom-Json
    $matchingFirewallRule = $firewallRules | Where-Object { $_.startIpAddress -eq $startIpAddress -and $_.endIpAddress -eq $endIpAddress }
    if($matchingFirewallRule)
    {
        $AccessRuleName = $matchingFirewallRule.name
    }
    else
    {
        throw "Could not find a matching accessrule to delete."
    }
}

# Execute whitelist
Invoke-Executable az mysql server firewall-rule delete --resource-group $MySqlServerResourceGroupName --server-name $MySqlServerName --name $AccessRuleName --yes

Write-Footer -ScopedPSCmdlet $PSCmdlet