[CmdletBinding()]
param (
    [Alias("StorageResourceGroupName")]
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter()][string][ValidateSet("BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2")] $StorageAccountKind = "StorageV2",
    [Parameter()][string][ValidateSet("Premium_LRS", "Premium_ZRS", "Standard_GRS", "Standard_GZRS", "Standard_LRS", "Standard_RAGRS", "Standard_RAGZRS", "Standard_ZRS")] $StorageAccountSku = "Standard_LRS",
    [Parameter()][bool] $StorageAccountAllowBlobPublicAccess = $false,
    [Parameter()][string][ValidateSet("TLS1_0", "TLS1_1", "TLS1_2")] $StorageAccountMinimalTlsVersion = "TLS1_2",

    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $StorageAccountPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $StorageAccountPrivateEndpointVnetName,
    [Parameter()][string] $StorageAccountPrivateEndpointSubnetName,
    [Parameter()][string] $PrivateEndpointGroupId,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $StorageAccountPrivateDnsZoneName = "privatelink.blob.core.windows.net",

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Diagnostic Settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$ApplicationVnetResourceGroupName -or !$ApplicationVnetName -or !$ApplicationSubnetName) -and (!$StorageAccountPrivateEndpointVnetResourceGroupName -or !$StorageAccountPrivateEndpointVnetName -or !$StorageAccountPrivateEndpointSubnetName -or !$PrivateEndpointGroupId -or !$DNSZoneResourceGroupName -or !$StorageAccountPrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS version
Assert-TLSVersion -TlsVersion $StorageAccountMinimalTlsVersion

# Create StorageAccount with the appropriate tags
$storageAccountId = (Invoke-Executable az storage account create --name $StorageAccountName --resource-group $StorageAccountResourceGroupName --kind $StorageAccountKind --sku $StorageAccountSku --allow-blob-public-access $StorageAccountAllowBlobPublicAccess --min-tls-version $StorageAccountMinimalTlsVersion | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $storageAccountId -ResourceTags ${ResourceTags}
}

# VNET Whitelisting
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    Write-Host "VNET Whitelisting is desired. Adding the needed components."

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-StorageAccount.ps1" -StorageAccountName $StorageAccountName -StorageAccountResourceGroupName $StorageAccountResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName

    # Make sure the default action is "deny" which causes public traffic to be dropped.
    Invoke-Executable az storage account update --resource-group $StorageAccountResourceGroupName --name $StorageAccountName --default-action Deny
}

# Private Endpoint
if ($StorageAccountPrivateEndpointVnetName -and $StorageAccountPrivateEndpointVnetResourceGroupName -and $StorageAccountPrivateEndpointSubnetName -and $PrivateEndpointGroupId -and $DNSZoneResourceGroupName -and $StorageAccountPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch the basic information for creating the Private Endpoint
    $storageAccountId = (Invoke-Executable az storage account show --name $StorageAccountName --resource-group $StorageAccountResourceGroupName | ConvertFrom-Json).id
    $vnetId = (Invoke-Executable az network vnet show --resource-group $StorageAccountPrivateEndpointVnetResourceGroupName --name $StorageAccountPrivateEndpointVnetName | ConvertFrom-Json).id
    $storageAccountPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $StorageAccountPrivateEndpointVnetResourceGroupName --name $StorageAccountPrivateEndpointSubnetName --vnet-name $StorageAccountPrivateEndpointVnetName | ConvertFrom-Json).id
    $storageAccountPrivateEndpointName = "$($StorageAccountName)-pvtstg-$($PrivateEndpointGroupId)"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $storageAccountPrivateEndpointSubnetId -PrivateEndpointName $storageAccountPrivateEndpointName -PrivateEndpointResourceGroupName $StorageAccountResourceGroupName -TargetResourceId $storageAccountId -PrivateEndpointGroupId $PrivateEndpointGroupId -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $StorageAccountPrivateDnsZoneName -PrivateDnsLinkName "$($StorageAccountPrivateEndpointVnetName)-storage"

    # Make sure the default action is "deny" which causes public traffic to be dropped.
    Invoke-Executable az storage account update --resource-group $StorageAccountResourceGroupName --name $StorageAccountName --default-action Deny
}

# Enable diagnostic settings for storage account
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $storageAccountId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $StorageAccountName
}
else
{
    Set-DiagnosticSettings -ResourceId $storageAccountId -ResourceName $StorageAccountName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet