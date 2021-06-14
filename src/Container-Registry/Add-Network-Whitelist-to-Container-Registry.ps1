[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerRegistryName,
    [Parameter(Mandatory)][string] $ContainerRegistryResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetToWhitelistSubnetName,
    [Parameter()][string] $SubnetToWhitelistVnetName,
    [Parameter()][string] $SubnetToWhitelistVnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToWhiteList = Get-CIDRForWhitelist -CIDR:$CIDRToWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetToWhitelistSubnetName -VnetName:$SubnetToWhitelistVnetName -VnetResourceGroupName:$SubnetToWhitelistVnetResourceGroupName 

# Fetch Subnet ID when subnet option is given.
if ($SubnetToWhitelistSubnetName -and $SubnetToWhitelistVnetName -and $SubnetToWhitelistVnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToWhitelistVnetResourceGroupName --name $SubnetToWhitelistSubnetName --vnet-name $SubnetToWhitelistVnetName | ConvertFrom-Json).id
    
    # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $subnetResourceId -ServiceEndpointServiceIdentifier 'Microsoft.ContainerRegistry'
}

# Check if the rule already exists, throw error
$optionalParameters = @()
$existingRules = Invoke-Executable az acr network-rule list --resource-group $ContainerRegistryResourceGroupName --name $ContainerRegistryName | ConvertFrom-Json
if ($CIDRToWhitelist)
{
    $optionalParameters += "--ip-address", "$CIDRToWhitelist"
    $ipRule = $existingRules.ipRules | Where-Object { $_.ipAddressOrRange -eq $CIDRToWhitelist.split('/')[0] }
    if ($ipRule)
    {
        Write-Warning "This CIDR is already added. Please correct this."
        return
    }
}
elseif ($subnetResourceId)
{
    $optionalParameters += "--subnet", "$subnetResourceId"
    $virtualNetworkRule = $existingRules.virtualNetworkRules | Where-Object { $_.virtualNetworkResourceId -eq $subnetResourceId }
    if ($virtualNetworkRule)
    {
        Write-Warning "This subnet is already added. Please correct this."
        return
    }
}

Invoke-Executable az acr network-rule add --name $ContainerRegistryName --resource-group $ContainerRegistryResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet