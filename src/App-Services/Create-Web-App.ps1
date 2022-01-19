[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,    
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias('LogAnalyticsWorkspaceName')]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory, ParameterSetName = 'default')][Parameter(Mandatory, ParameterSetName = 'DeploymentSlot')][string] $AppServiceRunTime,
    [Parameter()][string] $AppServiceNumberOfInstances = 2,
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter()][bool] $StopAppServiceImmediatelyAfterCreation = $false,
    [Parameter()][bool] $StopAppServiceSlotImmediatelyAfterCreation = $false,
    [Parameter()][bool] $AppServiceAlwaysOn = $true,
    [Parameter()][string][ValidateSet('1.0', '1.1', '1.2')] $AppServiceMinimalTlsVersion = '1.2',
    
    # Deployment Slots
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableAppServiceDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $AppServiceDeploymentSlotName = 'staging',
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForAppServiceDeploymentSlot = $true,
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $DisableVNetWhitelistForDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $DisablePrivateEndpointForDeploymentSlot,

    # Use container image name with optional tag for example thelastpickle/cassandra-reaper:latest
    [Parameter(Mandatory, ParameterSetName = 'Container')][Parameter(ParameterSetName = 'DeploymentSlot')][string] $ContainerImageName,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Alias('VnetResourceGroupName')]
    [Parameter()][string] $AppServicePrivateEndpointVnetResourceGroupName,
    [Alias('VnetName')]
    [Parameter()][string] $AppServicePrivateEndpointVnetName,
    [Alias('ApplicationPrivateEndpointSubnetName')]
    [Parameter()][string] $AppServicePrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias('PrivateDnsZoneName')]
    [Parameter()][string] $AppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net',
    
    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic,
    
    # Acknowledge that the website for additional slots are truncated
    [Parameter()][switch] $SuppressTruncatedSiteName,

    # Diagnostic settings
    [Parameter()][System.Object[]] $DiagnosticSettingsLogs,
    [Parameter()][System.Object[]] $DiagnosticSettingsMetrics,
    
    # Disable diagnostic settings
    [Parameter()][switch] $DiagnosticSettingsDisabled,

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Web-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($AppServiceName.Length -gt 40)
{
    Write-Warning 'Please note that the App Service name is longer than 40 characters. This can give some unexpected urls for additional slots.'
    Write-Warning 'See last paragraph of https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots#add-a-slot.'
    if (!$SuppressTruncatedSiteName)
    {
        Write-Host '##vso[task.complete result=SucceededWithIssues;]'
    } 
}

if ((!$GatewayVnetResourceGroupName -or !$GatewayVnetName -or !$GatewaySubnetName -or !$GatewayWhitelistRulePriority) -and (!$AppServicePrivateEndpointVnetResourceGroupName -or !$AppServicePrivateEndpointVnetName -or !$AppServicePrivateEndpointSubnetName -or !$DNSZoneResourceGroupName -or !$AppServicePrivateDnsZoneName))
{
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

# Check TLS Version
Assert-TLSVersion -TlsVersion $AppServiceMinimalTlsVersion

# Fetch AppService Plan ID
$appServicePlan = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json)

#adding additional parameters
$optionalParameters = @()

# This only works with app services running in Linux
if ($ContainerImageName -and $appServicePlan.kind -ne 'Linux')
{
    throw 'Container images can only be added directly to Linux webapps. Please add this webapp to the correct AppServicePlan.'
}
elseif ($ContainerImageName)
{
    $optionalParameters += '--deployment-container-image-name', "$ContainerImageName"
}
elseif ($AppServiceRunTime)
{
    # Appservice runtime and container image name cannot be used together.
    $optionalParameters += '--runtime', "$AppServiceRunTime"
}

# Create/Update AppService & Fetch the ID from the AppService
$webAppId = (Invoke-Executable az webapp create --name $AppServiceName --plan $appServicePlan.id --resource-group $AppServiceResourceGroupName --tags @ResourceTags @optionalParameters | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $webAppId -ResourceTags ${ResourceTags}
}

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

# Diagnostic Settings
if ($DiagnosticSettingsDisabled)
{
    Remove-DiagnosticSetting -ResourceId $webAppId -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -ResourceName $AppServiceName
}
else
{
    Set-DiagnosticSettings -ResourceId $webAppId -ResourceName $AppServiceName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -DiagnosticSettingsLogs:$DiagnosticSettingsLogs -DiagnosticSettingsMetrics:$DiagnosticSettingsMetrics 
}

# Create & Assign WebApp identity to AppService
Invoke-Executable az webapp identity assign --ids $webAppId

# Create Deployment Slot
if ($EnableAppServiceDeploymentSlot)
{
    $parametersForDeploymentSlot = @{ 
        AppType                                      = 'webapp'; 
        ResourceResourceGroupName                    = $AppServiceResourceGroupName;    
        ResourceName                                 = $AppServiceName; 
        ResourceDeploymentSlotName                   = $AppServiceDeploymentSlotName;
        LogAnalyticsWorkspaceResourceId              = $LogAnalyticsWorkspaceResourceId;
        StopResourceSlotImmediatelyAfterCreation     = $StopAppServiceSlotImmediatelyAfterCreation;
        ResourceTags                                 = ${ResourceTags};
        ResourceAlwaysOn                             = $AppServiceAlwaysOn;
        ResourceMinimalTlsVersion                    = $AppServiceMinimalTlsVersion;
        DisablePublicAccessForResourceDeploymentSlot = $DisablePublicAccessForAppServiceDeploymentSlot;
        ForcePublic                                  = $ForcePublic;
        GatewayVnetResourceGroupName                 = $GatewayVnetResourceGroupName;
        GatewayVnetName                              = $GatewayVnetName;
        GatewaySubnetName                            = $GatewaySubnetName;
        GatewayWhitelistRulePriority                 = $GatewayWhitelistRulePriority;
        ResourcePrivateEndpointVnetResourceGroupName = $AppServicePrivateEndpointVnetResourceGroupName;
        ResourcePrivateEndpointVnetName              = $AppServicePrivateEndpointVnetName;
        ResourcePrivateEndpointSubnetName            = $AppServicePrivateEndpointSubnetName;
        DNSZoneResourceGroupName                     = $DNSZoneResourceGroupName;
        ResourcePrivateDnsZoneName                   = $AppServicePrivateDnsZoneName;
        ResourceDisableVNetWhitelisting              = $DisableVNetWhitelistForDeploymentSlot;
        ResourceDisablePrivateEndpoints              = $DisablePrivateEndpointForDeploymentSlot;
        DiagnosticSettingsLogs                       = $DiagnosticSettingsLogs;
        DiagnosticSettingsMetrics                    = $DiagnosticSettingsMetrics;
        DiagnosticSettingsDisabled                   = $DiagnosticSettingsDisabled;
    }

    New-DeploymentSlot @parametersForDeploymentSlot
}

# VNET Whitelisting
if ($GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
{
    # REMOVE OLD NAMES
    $oldAccessRestrictionRuleName = ToMd5Hash -InputString "$($GatewayVnetName)_$($GatewaySubnetName)_allow"
    Remove-AccessRestrictionIfExists -AppType webapp -ResourceGroupName $AppServiceResourceGroupName -ResourceName $AppServiceName -AccessRestrictionRuleName $oldAccessRestrictionRuleName -AutoGeneratedAccessRestrictionRuleName $False
    # END REMOVE OLD NAMES

    Write-Host 'VNET Whitelisting is desired. Adding the needed components.'

    # Whitelist VNET
    & "$PSScriptRoot\Add-Network-Whitelist-to-App-Service.ps1" -AppServiceResourceGroupName $AppServiceResourceGroupName -AppServiceName $AppServiceName -AccessRestrictionRuleDescription:$AppServiceName -Priority $GatewayWhitelistRulePriority -ApplyToMainEntrypoint $true -ApplyToScmEntryPoint $true -SubnetToWhitelistSubnetName $GatewaySubnetName -SubnetToWhitelistVnetName $GatewayVnetName -SubnetToWhitelistVnetResourceGroupName $GatewayVnetResourceGroupName
}

# Add private endpoint & Setup Private DNS
if ($AppServicePrivateEndpointVnetResourceGroupName -and $AppServicePrivateEndpointVnetName -and $AppServicePrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $AppServicePrivateDnsZoneName)
{
    Write-Host 'A private endpoint is desired. Adding the needed components.'
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $AppServicePrivateEndpointVnetResourceGroupName --name $AppServicePrivateEndpointVnetName | ConvertFrom-Json).id
    $applicationPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $AppServicePrivateEndpointVnetResourceGroupName --name $AppServicePrivateEndpointSubnetName --vnet-name $AppServicePrivateEndpointVnetName | ConvertFrom-Json).id
    $appServicePrivateEndpointName = "$($AppServiceName)-pvtapp"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $applicationPrivateEndpointSubnetId -PrivateEndpointName $appServicePrivateEndpointName -PrivateEndpointResourceGroupName $AppServiceResourceGroupName -TargetResourceId $webAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $AppServicePrivateDnsZoneName -PrivateDnsLinkName "$($AppServicePrivateEndpointVnetName)-appservice"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet