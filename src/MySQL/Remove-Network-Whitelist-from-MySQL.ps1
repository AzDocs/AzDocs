[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $MySqlServerName,
    [Parameter(Mandatory)][string] $MySqlServerResourceGroupName,
    [Parameter()][string] $AccessRuleName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $SubnetToRemoveSubnetName,
    [Parameter()][string] $SubnetToRemoveVnetName,
    [Parameter()][string] $SubnetToRemoveVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -SubnetName:$SubnetToRemoveSubnetName -VnetName:$SubnetToRemoveVnetName -VnetResourceGroupName:$SubnetToRemoveVnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
if (!$AccessRuleName)
{
    $CIDRToRemoveFromWhitelist = Get-CIDRForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetToRemoveSubnetName -VnetName:$SubnetToRemoveVnetName -VnetResourceGroupName:$SubnetToRemoveVnetResourceGroupName 
}

# Fetch Subnet ID when subnet option is given.
if ($SubnetToRemoveSubnetName -and $SubnetToRemoveVnetName -and $SubnetToRemoveVnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToRemoveVnetResourceGroupName --name $SubnetToRemoveSubnetName --vnet-name $SubnetToRemoveVnetName | ConvertFrom-Json).id
}

if (!$subnetResourceId)
{
    Remove-FirewallRulesIfExists -ServiceType 'mysql' -ResourceGroupName $MySqlServerResourceGroupName -ResourceName $MySqlServerName -AccessRuleName:$AccessRuleName -CIDR:$CIDRToRemoveFromWhitelist
}
else
{
    Remove-VnetRulesIfExists -ServiceType 'mysql' -ResourceGroupName $MySqlServerResourceGroupName -ResourceName $MySqlServerName -AccessRuleName:$AccessRuleName -SubnetResourceId:$subnetResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet