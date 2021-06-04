[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

# TODO - Create a common function for checking the matched firewall/vnet rules

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($CIDRToRemoveFromWhitelist -and $SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    throw "You can not enter a CIDRToWhitelist (CIDR whitelisting) in combination with SubnetName, VnetName, VnetResourceGroupName (Subnet whitelisting). Choose one of the two options."
}

# Autogenerate CIDR if no CIDR or Subnet is passed
if (!$CIDRToRemoveFromWhitelist -and !$AccessRuleName -and (!$SubnetName -or !$VnetName -or !$VnetResourceGroupName))
{
    $response = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToRemoveFromWhitelist = $response.Content.Trim() + '/32'
}

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

# Check if rules exist and if so, remove.
$matchedFirewallRules = [Collections.Generic.List[string]]::new()
$matchedVnetRules = [Collections.Generic.List[string]]::new()
if (!$subnetResourceId)
{
    $firewallRules = Invoke-Executable az postgres server firewall-rule list --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName | ConvertFrom-Json
    if ($AccessRuleName)
    {
        $matchingFirewallRules = $firewallRules | Where-Object { $_.name -eq $AccessRuleName }
        if ($matchingFirewallRules)
        {
            $matchedFirewallRules.Add($AccessRuleName)
        }
    }
    else
    {
        $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToRemoveFromWhitelist
        $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToRemoveFromWhitelist
        $matchingFirewallRules = $firewallRules | Where-Object { $_.startIpAddress -eq $startIpAddress -and $_.endIpAddress -eq $endIpAddress }
        if ($matchingFirewallRules)
        {
            foreach ($matchingFirewallRule in $matchingFirewallRules)
            {
                $matchedFirewallRules.Add($matchingFirewallRule.name)
            }
        }
    }
}
else
{
    $vnetRules = Invoke-Executable az postgres server vnet-rule list --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName | ConvertFrom-Json
    if ($AccessRuleName)
    {
        $matchingVnetRules = $vnetRules | Where-Object { $_.name -eq $AccessRuleName }
        if ($matchingVnetRules)
        {
            $matchedVnetRules.Add($AccessRuleName)
        }
    }
    else
    {
        $matchingVnetRules = $vnetRules | Where-Object { $_.virtualNetworkSubnetId -eq $subnetResourceId }
        if ($matchingVnetRules)
        {
            foreach ($matchingVnetRule in $matchingVnetRules)
            {
                $matchedVnetRules.Add($matchingVnetRule.name)
            }
        }
    }
}

# Remove firewall rules
foreach ($ruleName in $matchedFirewallRules) 
{
    Write-Host "Removing whitelist for $ruleName."
    Invoke-Executable az postgres server firewall-rule delete --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $ruleName --yes
}

# Remove vnet rules
foreach ($ruleName in $matchedVnetRules) 
{
    Write-Host "Removing whitelist for $ruleName."
    Invoke-Executable az postgres server vnet-rule delete --resource-group $PostgreSqlServerResourceGroupName --server-name $PostgreSqlServerName --name $ruleName
}

Write-Footer -ScopedPSCmdlet $PSCmdlet