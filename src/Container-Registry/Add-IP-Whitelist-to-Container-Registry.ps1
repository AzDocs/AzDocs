[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

# TODO: REMOVE => Container registry kan geen dubbele ip addressen opslaan. Update niet de waarden.
# TODO: REMOVE => Bestaande waarden eerst removen en dan opnieuw opslaan.

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($CIDRToWhitelist -and $SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    throw "You can not enter a CIDRToWhitelist (CIDR whitelisting) in combination with SubnetName, VnetName, VnetResourceGroupName (Subnet whitelisting). Choose one of the two options."
}

# Autogenerate CIDR if no CIDR or Subnet is passed
if (!$CIDRToWhitelist -and (!$SubnetName -or !$VnetName -or !$VnetResourceGroupName))
{
    $response = Invoke-WebRequest 'https://ipinfo.io/ip'
    $CIDRToWhitelist = $response.Content.Trim() + '/32'
}

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

# Check if the rule already exists, then remove it and add it again
$optionalParameters = @()
$existingRules = Invoke-Executable az acr network-rule list --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName | ConvertFrom-Json
if ($CIDRToWhitelist)
{
    $optionalParameters += "--ip-address", "$CIDRToWhitelist"
    $ipRule = $existingRules.ipRules | Where-Object { $_.ipAddressOrRange -eq $CIDRToWhitelist.split('/')[0] }
    if ($ipRule)
    {
        Invoke-Executable az acr network-rule remove --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --ip-address $ipRule.ipAddressOrRange
    }
}
elseif ($subnetResourceId)
{
    $optionalParameters += "--subnet", "$subnetResourceId"
    $virtualNetworkRule = $existingRules.virtualNetworkRules | Where-Object { $_.virtualNetworkResourceId -eq $subnetResourceId }
    if ($virtualNetworkRule)
    {
        Invoke-Executable az acr network-rule remove --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName --subnet $virtualNetworkRule.virtualNetworkResourceId
    }
}

Invoke-Executable az acr network-rule add --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet