[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetToWhitelistSubnetName,
    [Parameter()][string] $SubnetToWhitelistVnetName,
    [Parameter()][string] $SubnetToWhitelistVnetResourceGroupName
)

# TODO: REMOVE => SQL update firewall waarden IF ze dezelfde AccessRulename hebben. Een andere AccessRuleName, maar hetzelfde IP wordt geaccepteerd.
# TODO: REMOVE => SQL update vnet rules als ze dezelfde AccessRulename hebben. Een andere AccessRulename, maar hetzelfde vnet wordt geaccepteerd.

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$sqlServerLowerCase = $SqlServerName.ToLower()

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToWhiteList = Get-CIDRForWhitelist -CIDR:$CIDRToWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName 

# Autogenerate name if no name is given
$AccessRuleName = Get-AccessRestrictionRuleName -AccessRestrictionRuleName:$AccessRuleName -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName

# Fetch Subnet ID when subnet option is given.
if ($SubnetToWhitelistSubnetName -and $SubnetToWhitelistVnetName -and $SubnetToWhitelistVnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToWhitelistVnetResourceGroupName --name $SubnetToWhitelistSubnetName --vnet-name $SubnetToWhitelistVnetName | ConvertFrom-Json).id
}

if (!$subnetResourceId)
{
    # Preparation
    $startIpAddress = Get-StartIpInIpv4Network -SubnetCidr $CIDRToWhitelist
    $endIpAddress = Get-EndIpInIpv4Network -SubnetCidr $CIDRToWhitelist

    $firewallRules = ((Invoke-Executable az sql server firewall-rule list --server $sqlServerLowerCase --resource-group $SqlServerResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.startIp -eq $startIpAddress -and $_.endIp -eq $endIpAddress -and $_.name -notlike "*/$AccessRuleName" }
    if ($firewallRules.Length -gt 0)
    {
        throw "This CIDR already exists with a different name. Please correct this."
    }

    # Execute whitelist
    Invoke-Executable az sql server firewall-rule create --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name $AccessRuleName --start-ip-address $startIpAddress --end-ip-address $endIpAddress
}
else
{
    $vnetRules = ((Invoke-Executable az sql server vnet-rule list --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase ) | ConvertFrom-Json) | Where-Object { $_.virtualNetworkSubnetId -eq $subnetResourceId -and $_.name -notlike "*/$AccessRuleName" }
    if ($vnetRules.Length -gt 0)
    {
        throw "This subnet already exists with a different name. Please correct this."
    }

    # Add subnet rule
    Invoke-Executable az sql server vnet-rule create --resource-group $SqlServerResourceGroupName --server $sqlServerLowerCase --name $AccessRuleName --subnet $subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet