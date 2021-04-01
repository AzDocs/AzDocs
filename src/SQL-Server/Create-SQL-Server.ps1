[CmdletBinding()]
param (
    [Alias("SubscriptionId")]
    [Parameter(Mandatory)][string] $SqlServerSubscriptionId,
    [Parameter(Mandatory)][string] $SqlServerPassword,
    [Parameter(Mandatory)][string] $SqlServerUsername,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Alias("LogAnalyticsWorkspaceId")]
    [Parameter()][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter()][ValidateSet('1.0', '1.1', '1.2')][string] $SqlServerMinimalTlsVersion = '1.2',
    [Parameter()][bool] $SqlServerEnablePublicNetwork = $true,
    [Parameter()][bool] $SqlServerEnableAuditing = $false,

    # VNET Whitelisting Parameters
    [Parameter()][string] $ApplicationVnetResourceGroupName,
    [Parameter()][string] $ApplicationVnetName,
    [Parameter()][string] $ApplicationSubnetName,

    # Private Endpoints
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $SqlServerPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $SqlServerPrivateEndpointVnetName,
    [Parameter()][string] $SqlServerPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $SqlServerPrivateDnsZoneName = "privatelink.database.windows.net"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create SQL Server
if (!(Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName))
{
    Invoke-Executable az sql server create --admin-password $SqlServerPassword --admin-user $SqlServerUsername --name $SqlServerName --resource-group $SqlServerResourceGroupName --enable-public-network $SqlServerEnablePublicNetwork --minimal-tls-version $SqlServerMinimalTlsVersion
}

# Fetch the resource id for the just created SQL Server
$sqlServerId = (Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).id

if($SqlServerPrivateEndpointVnetResourceGroupName -and $SqlServerPrivateEndpointVnetName -and $SqlServerPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $SqlServerPrivateDnsZoneName)
{
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $SqlServerPrivateEndpointVnetResourceGroupName --name $SqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $SqlServerPrivateEndpointVnetResourceGroupName --name $SqlServerPrivateEndpointSubnetName --vnet-name $SqlServerPrivateEndpointVnetName | ConvertFrom-Json).id
    $sqlServerPrivateEndpointName = "$($SqlServerName)-pvtsql"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $sqlServerPrivateEndpointSubnetId -PrivateEndpointName $sqlServerPrivateEndpointName -PrivateEndpointResourceGroupName $SqlServerResourceGroupName -TargetResourceId $sqlServerId -PrivateEndpointGroupId sqlServer -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $SqlServerPrivateDnsZoneName -PrivateDnsLinkName "$($SqlServerPrivateEndpointVnetName)-sql"
}


if($ApplicationVnetResourceGroupName -and $ApplicationVnetName -and $ApplicationSubnetName)
{
    # Fetch the Subnet ID where the Application Resides in
    $applicationSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ApplicationVnetResourceGroupName --name $ApplicationSubnetName --vnet-name $ApplicationVnetName | ConvertFrom-Json).id

    # Add Service Endpoint to App Subnet to make sure we can connect to the service within the VNET
    Set-SubnetServiceEndpoint -SubnetResourceId $applicationSubnetId -ServiceEndpointServiceIdentifier "Microsoft.Sql"

    # Allow the Application Subnet to this SQL Server through a vnet-rule
    Invoke-Executable az sql server vnet-rule create --server $SqlServerName --name "$($ApplicationVnetName)_$($ApplicationSubnetName)_allow" --resource-group $SqlServerResourceGroupName --subnet $applicationSubnetId
}

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

if($SqlServerEnableAuditing)
{
    # Set auditing policy on SQL server
    Install-Module PowerShellGet -Force
    Install-Module -Name Az.Sql -Force
    $encryptedPassword = ConvertTo-SecureString -String $env:servicePrincipalKey -AsPlainText
    $pscredential = [PSCredential]::new($env:servicePrincipalId, $encryptedPassword)
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $env:tenantId -Subscription $SqlServerSubscriptionId
    Set-AzSqlServerAudit -ResourceGroupName $SqlServerResourceGroupName -ServerName $SqlServerName -LogAnalyticsTargetState Enabled -WorkspaceResourceId $LogAnalyticsWorkspaceResourceId
}

Write-Footer -ScopedPSCmdlet $PSCmdlet