[CmdletBinding()]
param (
    [Parameter()]
    [String] $subscriptionId,

    [Parameter()]
    [String] $vnetResourceGroupName,

    [Parameter()]
    [String] $vnetName,

    [Parameter()]
    [String] $sqlServerPrivateEndpointSubnetName,

    [Parameter()]
    [String] $applicationSubnetName,

    [Parameter()]
    [String] $sqlServerPassword,

    [Parameter()]
    [String] $sqlServerUsername,

    [Parameter()]
    [String] $sqlServerName,

    [Parameter()]
    [String] $sqlServerResourceGroupName,

    [Parameter()]
    [String] $DNSZoneResourceGroupName,

    [Parameter()]
    [String] $privateDnsZoneName = "privatelink.database.windows.net",

    [Parameter()]
    [String] $logAnalyticsWorkspaceId
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\Set-SubnetServiceEndpoint.ps1"
#endregion ===END IMPORTS===

$vnetId = (Invoke-Executable az network vnet show -g $vnetResourceGroupName -n $vnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $sqlServerPrivateEndpointSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show -g $vnetResourceGroupName -n $applicationSubnetName --vnet-name $vnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointName = "$($sqlServerName)-pvtsql"

# Create SQL Server
Invoke-Executable az sql server create --admin-password $sqlServerPassword --admin-user $sqlServerUsername --name $sqlServerName --resource-group $sqlServerResourceGroupName

# Disable private-endpoint-network-policies to be able to add a private route to SQL Server
Invoke-Executable az network vnet subnet update --ids $sqlServerPrivateEndpointSubnetId --disable-private-endpoint-network-policies true

# Fetch the resource id for the just created SQL Server
$sqlServerId = (Invoke-Executable az sql server show --name $sqlServerName --resource-group $sqlServerResourceGroupName | ConvertFrom-Json).id

# Create Private Endpoint
Invoke-Executable az network private-endpoint create --name $sqlServerPrivateEndpointName --resource-group $sqlServerResourceGroupName --subnet $sqlServerPrivateEndpointSubnetId --private-connection-resource-id $sqlServerId --group-id sqlServer --connection-name "$($sqlServerName)-connection"

# Add Private DNS zone & set it up
if([String]::IsNullOrWhiteSpace($(az network private-dns zone show -g $DNSZoneResourceGroupName -n $privateDnsZoneName)))
{
    Invoke-Executable az network private-dns zone create --resource-group $DNSZoneResourceGroupName --name $privateDnsZoneName
}

$dnsZoneId = (Invoke-Executable az network private-dns zone show --name $privateDnsZoneName --resource-group $DNSZoneResourceGroupName | ConvertFrom-Json).id

if([String]::IsNullOrWhiteSpace($(az network private-dns link vnet show --name "$($vnetName)-sql" --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName)))
{
    Invoke-Executable az network private-dns link vnet create --resource-group $DNSZoneResourceGroupName --zone-name $privateDnsZoneName --name "$($vnetName)-sql" --virtual-network $vnetId --registration-enabled false
}

Invoke-Executable az network private-endpoint dns-zone-group create --resource-group $sqlServerResourceGroupName --endpoint-name $sqlServerPrivateEndpointName --name "$($sqlServerName)-zonegroup" --private-dns-zone $dnsZoneId --zone-name sql

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceName "Microsoft.Sql"

#TODO: Check why this doesnt work - op verzoek van Rob Hofmann
# Add a firewall rule on SQL Server to allow the AppService vnet
#Invoke-Executable az sql server vnet-rule create --server $sqlServerName --name "$($applicationSubnetName)_allow" --resource-group $sqlServerResourceGroupName --subnet $applicationSubnetId

Write-Host "Checking if public access is disabled"
if((Invoke-Executable az sql server show -n $sqlServerName -g $sqlServerResourceGroupName | ConvertFrom-Json).publicNetworkAccess -eq "Enabled")
{
     # Update setting for Public Network Access
     Write-Host "Public access is enabled. Disabling it now."
     Invoke-Executable az sql server update -n $sqlServerName -g $sqlServerResourceGroupName --set publicNetworkAccess="Disabled"
}

# Set auditing policy on SQL server
Install-Module PowerShellGet -Force
Install-Module -Name Az.Sql -Force
$encryptedPassword = ConvertTo-SecureString -String $env:servicePrincipalKey -AsPlainText
$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($env:servicePrincipalId, $encryptedPassword)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $env:tenantId -Subscription $subscriptionId
Set-AzSqlServerAudit -ResourceGroupName $sqlServerResourceGroupName -ServerName $sqlServerName -LogAnalyticsTargetState Enabled -WorkspaceResourceId $logAnalyticsWorkspaceId