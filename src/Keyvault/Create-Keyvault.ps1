[CmdletBinding()]
param (
    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $keyvaultPrivateEndpointSubnetName,

    [Parameter()]
    [String] $applicationSubnetName,

    [Parameter()]
    [String] $keyvaultName,

    [Parameter()]
    [String] $keyvaultResourceGroupName,

    [Parameter()]
    [System.Object[]] $resourceTags,

    [Parameter()]
    [String] $keyvaultDiagnosticsName,

    [Parameter()]
    [String] $logAnalyticsWorkspaceName,

    [Parameter()]
    [String] $DNSZoneResourceGroupName,

    [Parameter()]
    [String] $privateDnsZoneName = "privatelink.vaultcore.azure.net"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===


$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$keyvaultPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $keyvaultPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $applicationSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$keyVaultPrivateEndpointName = "$($keyvaultName)-pvtkv"

# Create KeyVault with the appropriate tags
Invoke-Executable az keyvault create --name $keyvaultName --resource-group $keyvaultResourceGroupName --default-action Deny --sku standard --bypass None --tags ${resourceTags}

# Fetch the Keyvault ID to use while creating the Diagnostics settings in the next step
$keyvaultId = (Invoke-Executable az keyvault show --name $keyvaultName --resource-group $keyvaultResourceGroupName | ConvertFrom-Json).id

# Create diagnostics settings for the Keyvault resource
Invoke-Executable az monitor diagnostic-settings create --resource $keyvaultId --name $keyvaultDiagnosticsName --workspace $logAnalyticsWorkspaceName --logs "[{ 'category': 'AuditEvent', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Disable Private Endpoint policies, else we cannot add the private endpoint to this subnet
Invoke-Executable az network vnet subnet update --ids $keyvaultPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Create the Private Endpoint based on the resource id fetched in the previous step.
Invoke-Executable az network private-endpoint create --name $keyVaultPrivateEndpointName --resource-group $keyvaultResourceGroupName --subnet $keyvaultPrivateEndpointSubnetId --private-connection-resource-id $keyvaultId --group-id vault --connection-name "$($keyvaultName)-connection"

# Create Private DNS Zone for this service. This will enable us to get dynamic IP's within the subnet which will keep traffic within the subnet
if ([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName))) {
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $privateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if ([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-keyvault" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName))) {
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-keyvault" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $keyvaultResourceGroupName --endpoint-name $keyVaultPrivateEndpointName --name "$($keyvaultName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name keyvault


#### i dont think we need this, but we need to check
# Create DNS Record for the private endpoint
$privateEndpoint = Invoke-Executable az network private-endpoint show --resource-group $keyvaultResourceGroupName --name $keyVaultPrivateEndpointName | ConvertFrom-Json
$networkInterface = Invoke-Executable az network nic show --ids $privateEndpoint.networkInterfaces.id | ConvertFrom-Json
if (!$networkInterface -or !$networkInterface.ipConfigurations -or !$networkInterface.ipConfigurations[0] -or !$networkInterface.ipConfigurations[0].privateIpAddress) {
    throw "Private endpoint not configured correctly!"
}
$keyVaultPrivateIp = $networkInterface.ipConfigurations[0].privateIpAddress

$records = az network private-dns record-set a list --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName | ConvertFrom-Json
$keyvaultRecords = $records | Where-Object { $_.name -eq $keyvaultName }
if (-not $keyvaultRecords) {
    Write-Host 'Private dns record fornot found, adding a new record'
    Invoke-Executable az network private-dns record-set a add-record --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --record-set-name $keyvaultName --ipv4-address $keyVaultPrivateIp
}
elseif ($keyvaultRecords.aRecords.ipv4Address -ne $keyVaultPrivateIp) {
    Write-Host 'Private dns record found with a different ip address'

    Write-Host 'Removing record'
    Invoke-Executable az network private-dns record-set a delete --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name $keyvaultName

    Write-Host 'Adding new a-record'
    Invoke-Executable az network private-dns record-set a add-record --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --record-set-name $keyvaultName --ipv4-address $keyVaultPrivateIp
}
else {
    Write-Host 'Private dns record found with the correct ip address, no action required'
}
#### END OF i dont think we need this, but we need to check


# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceName "Microsoft.KeyVault"

# Whitelist our App's subnet in the keyvault so we can connect
Invoke-Executable az keyvault network-rule add --resource-group $keyvaultResourceGroupName --name $keyvaultName --subnet $applicationSubnetId