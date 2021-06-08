[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter()][ValidatePattern('^$|^(?:(?:\d{1,3}.){3}\d{1,3})(?:\/(?:\d{1,2}))?$', ErrorMessage = "The text '{0}' does not match with the CIDR notation, like '1.2.3.4/32'")][string] $CIDRToWhitelist,
    [Parameter()][string] $SubnetName,
    [Parameter()][string] $VnetName,
    [Parameter()][string] $VnetResourceGroupName
)

# TODO: REMOVE => Storage account update de waarden. Geen dubbele waarden aanwezig. Geen issues met bestaat al.
# TODO: NO CIDRSuffix

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Confirm if the correct parameters are passed
Confirm-ParametersForWhitelist -CIDR:$CIDRToWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName

# Autogenerate CIDR if no CIDR or Subnet is passed
$CIDRToWhiteList = New-CIDR -CIDR:$CIDRToWhitelist -SubnetName:$SubnetName -VnetName:$VnetName -VnetResourceGroupName:$VnetResourceGroupName 

# Fetch Subnet ID when subnet option is given.
if ($SubnetName -and $VnetName -and $VnetResourceGroupName)
{
    $subnetResourceId = (Invoke-Executable az network vnet subnet show --resource-group $VnetResourceGroupName --name $SubnetName --vnet-name $VnetName | ConvertFrom-Json).id
}

$optionalParameters = @()
if ($CIDRToWhitelist)
{
    $optionalParameters += "--ip-address", "$CIDRToWhitelist"
}
elseif ($subnetResourceId)
{
    $optionalParameters += "--subnet", "$subnetResourceId"
}

Invoke-Executable az storage account network-rule add --account-name $StorageAccountName --resource-group $StorageAccountResourceGroupName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet