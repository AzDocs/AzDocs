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

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToWhiteList = New-CIDR -CIDR:$CIDRToWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName 

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
        throw 'This CIDR is already added. Please correct this.'
    }
}
elseif ($subnetResourceId)
{
    $optionalParameters += "--subnet", "$subnetResourceId"
    $virtualNetworkRule = $existingRules.virtualNetworkRules | Where-Object { $_.virtualNetworkResourceId -eq $subnetResourceId }
    if ($virtualNetworkRule)
    {
        throw 'This subnet is already added. Please correct this.'
    }
}

Invoke-Executable az acr network-rule add --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet