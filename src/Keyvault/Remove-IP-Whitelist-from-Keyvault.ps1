[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToRemoveFromWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToRemoveFromWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToRemoveFromWhitelist = New-CIDR -CIDR:$CIDRToRemoveFromWhitelist -CIDRSuffix '/32' -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName 

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
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

Invoke-Executable az keyvault network-rule remove --name $KeyvaultName --resource-group $KeyvaultResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet