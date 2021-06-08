[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter()][string] $KeyvaultDiagnosticsName,
    [Parameter()][string] $LogAnalyticsWorkspaceName,

    # VNET Whitelisting
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $KeyvaultPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $KeyvaultPrivateEndpointVnetName,
    [Parameter()][string] $KeyvaultPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $KeyvaultPrivateDnsZoneName = "privatelink.vaultcore.azure.net"
    
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Check if keyvault needs to be created. Warning: az keyvault create is not idempotent: https://github.com/Azure/azure-cli/issues/13752
$keyvaultExists = (Invoke-Executable az keyvault list --resource-group $KeyvaultResourceGroupName --resource-type 'vault' | ConvertFrom-Json) | Where-Object { $_.name -eq $KeyvaultName }
if (!$keyvaultExists)
{
    Invoke-Executable az keyvault create --name $KeyvaultName --resource-group $KeyvaultResourceGroupName --default-action Deny --sku standard --bypass None --tags ${ResourceTags}
}

# Fetch the Keyvault ID to use while creating the Diagnostics settings in the next step
$keyvaultId = (Invoke-Executable az keyvault show --name $KeyvaultName --resource-group $KeyvaultResourceGroupName | ConvertFrom-Json).id

# Create diagnostics settings for the Keyvault resource
if ($KeyvaultDiagnosticsName -and $LogAnalyticsWorkspaceName)
{
    Invoke-Executable az monitor diagnostic-settings create --resource $keyvaultId --name $KeyvaultDiagnosticsName --workspace $LogAnalyticsWorkspaceName --logs "[{ 'category': 'AuditEvent', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')
}

# Private Endpoint
if ($KeyvaultPrivateEndpointVnetResourceGroupName -and $KeyvaultPrivateEndpointVnetName -and $KeyvaultPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $KeyvaultPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $KeyvaultPrivateEndpointVnetResourceGroupName --name $KeyvaultPrivateEndpointVnetName | ConvertFrom-Json).id
    $keyvaultPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $KeyvaultPrivateEndpointVnetResourceGroupName --name $KeyvaultPrivateEndpointSubnetName --vnet-name $KeyvaultPrivateEndpointVnetName | ConvertFrom-Json).id
    $keyVaultPrivateEndpointName = "$($KeyvaultName)-pvtkv"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $keyvaultPrivateEndpointSubnetId -PrivateEndpointName $keyVaultPrivateEndpointName -PrivateEndpointResourceGroupName $KeyvaultResourceGroupName -TargetResourceId $keyvaultId -PrivateEndpointGroupId vault -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $KeyvaultPrivateDnsZoneName -PrivateDnsLinkName "$($KeyvaultPrivateEndpointVnetName)-keyvault"
}

# VNET Whitelisting
if ($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    
    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-Keyvault.ps1" -KeyvaultName $KeyvaultName -KeyvaultResourceGroupName $KeyvaultResourceGroupName -SubnetToWhitelistSubnetName $ApplicationSubnetName -SubnetToWhitelistVnetName $ApplicationVnetName -SubnetToWhitelistVnetResourceGroupName $ApplicationVnetResourceGroupName

    # $applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id

    # # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    # Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.KeyVault"

    # # Whitelist our App's subnet in the keyvault so we can connect
    # Invoke-Executable az keyvault network-rule add --resource-group $KeyvaultResourceGroupName --name $KeyvaultName --subnet $applicationSubnetId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet