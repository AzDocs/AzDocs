[CmdletBinding()]
param (
    [Parameter()]
    [String] $VnetResourceGroupName,

    [Parameter()]
    [String] $VnetName,

    [Parameter()]
    [String] $SqlServerPrivateEndpointSubnetName,

    [Parameter()]
    [String] $ApplicationSubnetName,

    [Parameter()]
    [String] $SqlServerPassword,

    [Parameter()]
    [String] $SqlServerUsername,

    [Parameter()]
    [String] $SqlServerName,

    [Parameter()]
    [String] $SqlServerResourceGroupName,

    [Parameter()]
    [String] $DNSZoneResourceGroupName,

    [Parameter()]
    [String] $PrivateDnsZoneName = "privatelink.postgres.database.azure.com",

    [Parameter()]
    [String] $SqlServerSku,

    [Parameter()]
    [int] $BackupRetentionInDays = 7,

    [Parameter()]
    [String] $SqlServerVersion = "11"
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

Write-Header

$vnetId = (Invoke-Executable az network vnet show -g $VnetResourceGroupName -n $VnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $VnetResourceGroupName -n $SqlServerPrivateEndpointSubnetName --vnet-name $VnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show -g $VnetResourceGroupName -n $ApplicationSubnetName --vnet-name $VnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointName = "$($SqlServerName)-pvtpsql"

# Create PSQL Server if it does not exist
if([String]::IsNullOrWhiteSpace($(Invoke-Executable az postgres server show --name $SqlServerName --resource-group $SqlServerResourceGroupName)))
{
    Invoke-Executable az postgres server create --admin-password $SqlServerPassword --admin-user $SqlServerUsername --name $SqlServerName --resource-group $SqlServerResourceGroupName --sku-name $SqlServerSku --backup-retention $BackupRetentionInDays --assign-identity --public-network-access Disabled --version $SqlServerVersion
}

# Disable private-endpoint-network-policies to be able to add a private route to SQL Server
Invoke-Executable az network vnet subnet update --ids $sqlServerPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Fetch the resource id for the just created SQL Server
$sqlServerId = (Invoke-Executable az postgres server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).id

# Create Private Endpoint
Invoke-Executable az network private-endpoint create --name $sqlServerPrivateEndpointName --resource-group $SqlServerResourceGroupName --subnet $sqlServerPrivateEndpointSubnetId --private-connection-resource-id $sqlServerId --group-id postgresqlServer --connection-name "$($SqlServerName)-connection"

# Add Private DNS zone & set it up
if([String]::IsNullOrWhiteSpace($(Invoke-Executable -AllowToFail az network private-dns zone show -g $DNSZoneResourceGroupName -n $PrivateDnsZoneName)))
{
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $PrivateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $PrivateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if([String]::IsNullOrWhiteSpace($(Invoke-Executable -AllowToFail az network private-dns link vnet show --name "$($VnetName)-psql" --resource-group $DNSZoneResourceGroupName --zone-name $PrivateDnsZoneName)))
{
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $PrivateDnsZoneName --name "$($VnetName)-psql" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $SqlServerResourceGroupName --endpoint-name $sqlServerPrivateEndpointName --name "$($SqlServerName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name psql

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceName "Microsoft.Sql"

Write-Footer