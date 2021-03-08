[CmdletBinding()]
param (
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $KeyvaultPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $KeyvaultPrivateEndpointVnetName,
    [Parameter(Mandatory)][string] $KeyvaultPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $ApplicationVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationVnetName,
    [Parameter(Mandatory)][string] $ApplicationSubnetName,
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter()][string] $KeyvaultDiagnosticsName,
    [Parameter()][string] $LogAnalyticsWorkspaceName,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $KeyvaultPrivateDnsZoneName = "privatelink.vaultcore.azure.net"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetId = (Invoke-Executable az network vnet show --resource-group $KeyvaultPrivateEndpointVnetResourceGroupName --name $KeyvaultPrivateEndpointVnetName | ConvertFrom-Json).id
$keyvaultPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $KeyvaultPrivateEndpointVnetResourceGroupName --name $KeyvaultPrivateEndpointSubnetName --vnet-name $KeyvaultPrivateEndpointVnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id
$keyVaultPrivateEndpointName = "$($KeyvaultName)-pvtkv"

# Check if keyvault needs to be created. Warning: az keyvault create is not idempotent: https://github.com/Azure/azure-cli/issues/13752
$currentVaultsInResourceGroup = Invoke-Executable az keyvault list --resource-group $KeyvaultResourceGroupName --resource-type 'vault' | ConvertFrom-Json
$keyvaultExists = $currentVaultsInResourceGroup | Where-Object { $_.name -eq $KeyvaultName }

if (!$keyvaultExists) {
    Invoke-Executable az keyvault create --name $KeyvaultName --resource-group $KeyvaultResourceGroupName --default-action Deny --sku standard --bypass None --tags ${ResourceTags}
}

# Fetch the Keyvault ID to use while creating the Diagnostics settings in the next step
$keyvaultId = (Invoke-Executable az keyvault show --name $KeyvaultName --resource-group $KeyvaultResourceGroupName | ConvertFrom-Json).id

# Create diagnostics settings for the Keyvault resource
Invoke-Executable az monitor diagnostic-settings create --resource $keyvaultId --name $KeyvaultDiagnosticsName --workspace $LogAnalyticsWorkspaceName --logs "[{ 'category': 'AuditEvent', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $keyvaultPrivateEndpointSubnetId -PrivateEndpointName $keyVaultPrivateEndpointName -PrivateEndpointResourceGroupName $KeyvaultResourceGroupName -TargetResourceId $keyvaultId -PrivateEndpointGroupId vault -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $KeyvaultPrivateDnsZoneName -PrivateDnsLinkName "$($KeyvaultPrivateEndpointVnetName)-keyvault"

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.KeyVault"

# Whitelist our App's subnet in the keyvault so we can connect
Invoke-Executable az keyvault network-rule add --resource-group $KeyvaultResourceGroupName --name $KeyvaultName --subnet $applicationSubnetId

Write-Footer -ScopedPSCmdlet $PSCmdlet