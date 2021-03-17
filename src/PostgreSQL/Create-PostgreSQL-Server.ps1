[CmdletBinding()]
param (
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerPrivateEndpointVnetName,
    [Alias("SqlServerPrivateEndpointSubnetName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $ApplicationVnetName,
    [Parameter(Mandatory)][string] $ApplicationVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationSubnetName,
    [Alias("SqlServerPassword")]
    [Parameter(Mandatory)][string] $PostgreSqlServerPassword,
    [Alias("SqlServerUsername")]
    [Parameter(Mandatory)][string] $PostgreSqlServerUsername,
    [Alias("SqlServerName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerName,
    [Alias("SqlServerResourceGroupName")]
    [Parameter(Mandatory)][string] $PostgreSqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $PostgreSqlServerPrivateDnsZoneName = "privatelink.postgres.database.azure.com",
    [Alias("SqlServerSku")]
    [Parameter(Mandatory)][string] $PostgreSqlServerSku,
    [Parameter()][int] $BackupRetentionInDays = 7,
    [Alias("SqlServerVersion")]
    [Parameter()][string] $PostgreSqlServerVersion = "11"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetId = (Invoke-Executable az network vnet show --resource-group $PostgreSqlServerPrivateEndpointVnetResourceGroupName --name $PostgreSqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $PostgreSqlServerPrivateEndpointVnetResourceGroupName --name $PostgreSqlServerPrivateEndpointSubnetName --vnet-name $PostgreSqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointName = "$($PostgreSqlServerName)-pvtpsql"
$resourceGroupLocation = (az group show --name $PostgreSqlServerResourceGroupName | ConvertFrom-Json).location

Write-Host "Found location $($resourceGroupLocation)"
# Create PSQL Server if it does not exist
if(!$((Invoke-Executable -AllowToFail az postgres server show --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName | ConvertFrom-Json).Id))
{
    Write-Host "Creating Postgres server"
    Invoke-Executable az postgres server create --admin-password $PostgreSqlServerPassword --admin-user $PostgreSqlServerUsername --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName --location $resourceGroupLocation --sku-name $PostgreSqlServerSku --backup-retention $BackupRetentionInDays --assign-identity --public-network-access Disabled --version $PostgreSqlServerVersion
}

# Fetch the resource id for the just created SQL Server
$postgreSqlServerId = (Invoke-Executable az postgres server show --name $PostgreSqlServerName --resource-group $PostgreSqlServerResourceGroupName | ConvertFrom-Json).id

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $PostgreSqlServerResourceGroupName -TargetResourceId $postgreSqlServerId -PrivateEndpointGroupId postgresqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $PostgreSqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($PostgreSqlServerPrivateEndpointVnetName)-psql"

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.Sql"

Write-Footer -ScopedPSCmdlet $PSCmdlet