[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,    
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("LogAnalyticsWorkspaceName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory, ParameterSetName = 'default')][Parameter(Mandatory, ParameterSetName = 'DeploymentSlot')][string] $AppServiceRunTime,
    [Parameter()][string] $AppServiceNumberOfInstances = 2,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter()][bool] $StopAppServiceImmediatelyAfterCreation = $false,
    [Parameter()][bool] $StopAppServiceSlotImmediatelyAfterCreation = $false,
    [Parameter()][bool] $AppServiceAlwaysOn = $true,
    [Parameter()][string][ValidateSet("1.0", "1.1", "1.2")] $AppServiceMinimalTlsVersion = "1.2",
    
    # Deployment Slots
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableAppServiceDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $AppServiceDeploymentSlotName = 'staging',
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForAppServiceDeploymentSlot = $true,

    # Use container image name with optional tag for example thelastpickle/cassandra-reaper:latest
    [Parameter(Mandatory, ParameterSetName = 'Container')][string] $ContainerImageName,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $AppServicePrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $AppServicePrivateEndpointVnetName,
    [Alias("ApplicationPrivateEndpointSubnetName")]
    [Parameter()][string] $AppServicePrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $AppServicePrivateDnsZoneName = "privatelink.azurewebsites.net",
    
    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Web-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ((!$GatewayVnetResourceGroupName -or !$GatewayVnetName -or !$GatewaySubnetName -or !$GatewayWhitelistRulePriority) -and (!$AppServicePrivateEndpointVnetResourceGroupName -or !$AppServicePrivateEndpointVnetName -or !$AppServicePrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$AppServicePrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS Version
Assert-TLSVersion -TlsVersion $AppServiceMinimalTlsVersion

# Fetch AppService Plan ID
$appServicePlanId = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json).id

#adding additional parameters
$optionalParameters = @()

# This only works with app services running in Linux
if ($ContainerImageName)
{
    $optionalParameters += '--deployment-container-image-name', "$ContainerImageName"
}

if ($AppServiceRunTime)
{
    $optionalParameters += '--runtime', "$AppServiceRunTime"
}

# Fetch the ID from the AppService
$webAppId = (Invoke-Executable -AllowToFail az webapp show --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json).id

# Create/Update AppService
$webAppId = (Invoke-Executable az webapp create --name $AppServiceName --plan $appServicePlanId --resource-group $AppServiceResourceGroupName --tags ${ResourceTags} @optionalParameters | ConvertFrom-Json).id

# Update Tags
Set-ResourceTagsForResource -ResourceId $webAppId -ResourceTags ${ResourceTags}

## Update RunTime
#Set-AppServiceRunTime -AppServiceName $AppServiceName -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceRunTime $AppServiceRunTime


# Stop immediately if desired
if ($StopAppServiceImmediatelyAfterCreation)
{
    Invoke-Executable az webapp stop --name $AppServiceName --resource-group $AppServiceResourceGroupName
}

# Enforce HTTPS
Invoke-Executable az webapp update --ids $webAppId --https-only true

# Set Always On, the number of instances and the ftps-state to disable
Invoke-Executable az webapp config set --ids $webAppId --number-of-workers $AppServiceNumberOfInstances --always-on $AppServiceAlwaysOn --ftps-state Disabled --min-tls-version $AppServiceMinimalTlsVersion

# Set logging to FileSystem
Invoke-Executable az webapp log config --ids $webAppId --detailed-error-messages true --docker-container-logging filesystem --failed-request-tracing true --level warning --web-server-logging filesystem

#  Create diagnostics settings
Set-DiagnosticSettings -ResourceId $webAppId -ResourceName $AppServiceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'AppServiceHTTPLogs', 'enabled': true }, { 'category': 'AppServiceConsoleLogs', 'enabled': true }, { 'category': 'AppServiceAppLogs', 'enabled': true }, { 'category': 'AppServiceFileAuditLogs', 'enabled': true }, { 'category': 'AppServiceIPSecAuditLogs', 'enabled': true }, { 'category': 'AppServicePlatformLogs', 'enabled': true }, { 'category': 'AppServiceAuditLogs', 'enabled': true } ]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Create & Assign WebApp identity to AppService
Invoke-Executable az webapp identity assign --ids $webAppId

if ($EnableAppServiceDeploymentSlot)
{
    Invoke-Executable az webapp deployment slot create --resource-group $AppServiceResourceGroupName --name $AppServiceName --slot $AppServiceDeploymentSlotName

    # Stop immediately if desired
    if ($StopAppServiceSlotImmediatelyAfterCreation)
    {
        Invoke-Executable az webapp stop --name $AppServiceName --resource-group $AppServiceResourceGroupName --slot $AppServiceDeploymentSlotName
    }

    $webAppStagingId = (Invoke-Executable az webapp show --name $AppServiceName --resource-group $AppServiceResourceGroupName --slot $AppServiceDeploymentSlotName | ConvertFrom-Json).id
    Invoke-Executable az webapp config set --ids $webAppStagingId --number-of-workers $AppServiceNumberOfInstances --always-on $AppServiceAlwaysOn --ftps-state Disabled --min-tls-version $AppServiceMinimalTlsVersion --slot $AppServiceDeploymentSlotName
    Invoke-Executable az webapp log config --ids $webAppStagingId --detailed-error-messages true --docker-container-logging filesystem --failed-request-tracing true --level warning --web-server-logging filesystem --slot $AppServiceDeploymentSlotName
    Invoke-Executable az webapp identity assign --ids $webAppStagingId --slot $AppServiceDeploymentSlotName

    # Set diagnostic settings for deployment slot
    Set-DiagnosticSettings -ResourceId $webAppStagingId -ResourceName $AppServiceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'AppServiceHTTPLogs', 'enabled': true }, { 'category': 'AppServiceConsoleLogs', 'enabled': true }, { 'category': 'AppServiceAppLogs', 'enabled': true }, { 'category': 'AppServiceFileAuditLogs', 'enabled': true }, { 'category': 'AppServiceIPSecAuditLogs', 'enabled': true }, { 'category': 'AppServicePlatformLogs', 'enabled': true }, { 'category': 'AppServiceAuditLogs', 'enabled': true } ]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')
    
    if ($DisablePublicAccessForAppServiceDeploymentSlot)
    {
        $accessRestrictionRuleName = 'DisablePublicAccess'
        $cidr = '0.0.0.0/0'
        $accessRestrictionAction = 'Deny'
        
        Add-AccessRestriction -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $accessRestrictionRuleName -CIDR $cidr -AccessRestrictionAction $accessRestrictionAction -Priority 100000 -DeploymentSlotName $AppServiceDeploymentSlotName -AccessRestrictionRuleDescription $AppServiceName -ApplyToMainEntrypoint $True -ApplyToScmEntrypoint $True -AutoGeneratedAccessRestrictionRuleName $False
    }
}

# VNET Whitelisting
if ($GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
{
    # REMOVE OLD NAMES
    $oldAccessRestrictionRuleName = ToMd5Hash -InputString "$($GatewayVnetName)_$($GatewaySubnetName)_allow"
    Remove-AccessRestrictionIfExists -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $oldAccessRestrictionRuleName -AutoGeneratedAccessRestrictionRuleName $False
    # END REMOVE OLD NAMES

    Write-Host "VNET Whitelisting is desired. Adding the needed components."

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-App-Service.ps1" -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -AccessRestrictionRuleDescription:$AppServiceName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName
}

# Add private endpoint & Setup Private DNS
if ($AppServicePrivateEndpointVnetResourceGroupName -and $AppServicePrivateEndpointVnetName -and $AppServicePrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $AppServicePrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $AppServicePrivateEndpointVnetResourceGroupName --name $AppServicePrivateEndpointVnetName | ConvertFrom-Json).id
    $applicationPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $AppServicePrivateEndpointVnetResourceGroupName --name $AppServicePrivateEndpointSubnetName --vnet-name $AppServicePrivateEndpointVnetName | ConvertFrom-Json).id
    $appServicePrivateEndpointName = "$($AppServiceName)-pvtapp"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $applicationPrivateEndpointSubnetId -PrivateEndpointName $appServicePrivateEndpointName -PrivateEndpointResourceGroupName $AppServiceResourceGroupName -TargetResourceId $webAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $AppServicePrivateDnsZoneName -PrivateDnsLinkName "$($AppServicePrivateEndpointVnetName)-appservice"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet