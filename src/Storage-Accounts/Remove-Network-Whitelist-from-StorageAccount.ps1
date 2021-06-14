[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
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
$CIDRToRemoveFromWhitelist = Get-CIDRForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -SubnetName:$SubnetToRemoveSubnetName -VnetName:$SubnetToRemoveVnetName -VnetResourceGroupName:$SubnetToRemoveVnetResourceGroupName 
$CIDRToRemoveFromWhitelist = Confirm-CIDRForWhitelist -ServiceType 'storage' -CIDR:$CIDRToRemoveFromWhitelist

# Fetch Subnet ID when subnet option is given.
if ($SubnetToRemoveSubnetName -and $SubnetToRemoveVnetName -and $SubnetToRemoveVnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $SubnetToRemoveVnetResourceGroupName --name $SubnetToRemoveSubnetName --vnet-name $SubnetToRemoveVnetName | ConvertFrom-Json).id
}

$optionalParameters = @()
if ($CIDRToRemoveFromWhitelist)
{
    $optionalParameters += "--ip-address", "$CIDRToRemoveFromWhitelist"
}
elseif ($subnetResourceId)
{
    $optionalParameters += "--subnet", "$subnetResourceId"
}

Invoke-Executable az storage account network-rule remove --account-name $StorageAccountName --resource-group $StorageAccountResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet