[CmdletBinding()]
param (
    [Parameter()]
    [String] $applicationGatewayName,

    [Parameter()]
    [String] $applicationGatewayResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $gatewaySubnetName,

    [Parameter()]
    [String] $applicationGatewayCapacity,

    [Parameter()]
    [String] $applicationGatewaySku,

    [Parameter()]
    [String] $certificateKeyvaultName,

    [Parameter()]
    [String] $certificateKeyvaultResourceGroupName
)

$vnetId = (az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
Write-Host "VNET ID: $vnetId"
$gatewaySubnetId = (az network vnet subnet show -n $gatewaySubnetName --vnet-name $vnetName --resource-group $vnetResourceGroupName | ConvertFrom-Json).id
Write-Host "Gateway Subnet ID: $gatewaySubnetId"

az network public-ip create --resource-group $applicationGatewayResourceGroupName --name "$($applicationGatewayName)-publicip" --allocation-method Static --sku Standard

$publicIpId = (az network public-ip show --resource-group $applicationGatewayResourceGroupName --name "$($applicationGatewayName)-publicip" | ConvertFrom-Json).id

Write-Host "PublicIp: $publicIpId"

az network application-gateway create --name $applicationGatewayName --resource-group $applicationGatewayResourceGroupName --subnet $gatewaySubnetId --capacity $applicationGatewayCapacity --sku $applicationGatewaySku --http-settings-cookie-based-affinity Enabled --frontend-port 80 --http-settings-port 80 --http-settings-protocol Http --public-ip-address $publicIpId

az identity create --name $applicationGatewayName --resource-group $applicationGatewayResourceGroupName

$identityId = (az identity show --name "useridentity-$applicationGatewayName" --resource-group $applicationGatewayResourceGroupName | ConvertFrom-Json).id

Write-Host "AppGw Identity: $identityId"

az network application-gateway identity assign --resource-group $applicationGatewayResourceGroupName --gateway-name $applicationGatewayName --identity $identityId

# Add Service Endpoint to Gateway Subnet to make sure we can connect to the service within the VNET
$endpoints = az network vnet subnet show --ids $gatewaySubnetId --query=serviceEndpoints[].service --output=json | ConvertFrom-Json
if (![String]::IsNullOrWhiteSpace($endpoints) -and $endpoints -isnot [Object[]]) {
    $endpoints = @($endpoints)
}
Write-Host "Current service endpoints: $endpoints"
if (!($endpoints -contains 'Microsoft.KeyVault')) {
    Write-Host "Microsoft.KeyVault Service Endpoint isnt defined yet. Adding it to the list."
    $endpoints += "Microsoft.KeyVault"
}
az network vnet subnet update --ids $gatewaySubnetId --service-endpoints $endpoints

# Whitelist our Gateway's subnet in the Certificate Keyvault so we can connect
az keyvault network-rule add --resource-group $certificateKeyvaultResourceGroupName --name $certificateKeyvaultName --subnet $gatewaySubnetId