[CmdletBinding()]
param (
    [Alias("SubscriptionId")]
    [Parameter(Mandatory)][string] $SqlServerSubscriptionId,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $SqlServerPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $SqlServerPrivateEndpointVnetName,
    [Parameter(Mandatory)][string] $SqlServerPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $ApplicationVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationVnetName,
    [Parameter(Mandatory)][string] $ApplicationSubnetName,
    [Parameter(Mandatory)][string] $SqlServerPassword,
    [Parameter(Mandatory)][string] $SqlServerUsername,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $SqlServerPrivateDnsZoneName = "privatelink.database.windows.net",
    [Alias("LogAnalyticsWorkspaceId")]
    [Parameter()][string] $LogAnalyticsWorkspaceResourceId
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetId = (Invoke-Executable az network vnet show --resource-group $SqlServerPrivateEndpointVnetResourceGroupName --name $SqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $SqlServerPrivateEndpointVnetResourceGroupName --name $SqlServerPrivateEndpointSubnetName --vnet-name $SqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
$applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id
$sqlServerPrivateEndpointName = "$($SqlServerName)-pvtsql"

# Create SQL Server
Invoke-Executable az sql server create --admin-password $SqlServerPassword --admin-user $SqlServerUsername --name $SqlServerName --resource-group $SqlServerResourceGroupName --enable-public-network false

# Fetch the resource id for the just created SQL Server
$sqlServerId = (Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).id

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $SqlServerResourceGroupName -TargetResourceId $sqlServerId -PrivateEndpointGroupId sqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $SqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($SqlServerPrivateEndpointVnetName)-sql"

# Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.Sql"

#TODO: Issue created. You currently seem to have to enable public access before whitelisting subnets is allowed. Issue: https://github.com/Azure/azure-cli/issues/16771
# Add a firewall rule on SQL Server to allow the AppService vnet
# Invoke-Executable az sql server vnet-rule create --server $SqlServerName --name "$($ApplicationSubnetName)_allow" --resource-group $SqlServerResourceGroupName --subnet $applicationSubnetId
# Write-Host "Checking if public access is disabled"
# if((Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).publicNetworkAccess -eq "Enabled")
# {
#      # Update setting for Public Network Access
#      Write-Host "Public access is enabled. Disabling it now."
#      Invoke-Executable az sql server update --name $SqlServerName --resource-group $SqlServerResourceGroupName --set publicNetworkAccess="Disabled"
# }

# Set auditing policy on SQL server
Install-Module PowerShellGet -Force
Install-Module -Name Az.Sql -Force
$encryptedPassword = ConvertTo-SecureString -String $env:servicePrincipalKey -AsPlainText
$pscredential = New-Object -TypeName System.Management.Automation.PSCredential($env:servicePrincipalId, $encryptedPassword)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $env:tenantId -Subscription $SqlServerSubscriptionId
Set-AzSqlServerAudit -ResourceGroupName $SqlServerResourceGroupName -ServerName $SqlServerName -LogAnalyticsTargetState Enabled -WorkspaceResourceId $LogAnalyticsWorkspaceResourceId

Write-Footer -ScopedPSCmdlet $PSCmdlet