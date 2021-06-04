[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppStorageAccountName,
    [Parameter(Mandatory)][string] $FunctionAppDiagnosticsName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Alias("AlwaysOn")]
    [Parameter(Mandatory)][string] $FunctionAppAlwaysOn,
    [Parameter(Mandatory)][string] $FUNCTIONS_EXTENSION_VERSION,
    [Parameter(Mandatory)][string] $ASPNETCORE_ENVIRONMENT,
    [Parameter()][string] $FunctionAppNumberOfInstances = 2,
    [Parameter()][ValidateSet("dotnet-isolated", "dotnet", "node", "custom", "java", "powershell")][string] $FunctionAppRuntime = "dotnet",
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,

    # Deployment Slots
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableFunctionAppDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $FunctionAppDeploymentSlotName = "staging",
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForFunctionAppDeploymentSlot = $true,

    # VNET Whitelisting Parameters
    [Parameter()][string] $GatewayVnetResourceGroupName,
    [Parameter()][string] $GatewayVnetName,
    [Parameter()][string] $GatewaySubnetName,
    [Parameter()][string] $GatewayWhitelistRulePriority = 20,

    # Private Endpoint
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $FunctionAppPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter()][string] $FunctionAppPrivateEndpointVnetName,
    [Parameter()][string] $FunctionAppPrivateEndpointSubnetName,
    [Parameter()][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $FunctionAppPrivateDnsZoneName = "privatelink.azurewebsites.net",

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Function-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch AppService Plan ID
$appServicePlanId = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json).id

# Fetch the ID from the FunctionApp
$functionAppId = (Invoke-Executable -AllowToFail az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id

#TODO: az functionapp create is not idempotent, therefore the following fix. For more information, see https://github.com/Azure/azure-cli/issues/11863
if (!$functionAppId)
{
    # Create FunctionApp
    Invoke-Executable az functionapp create --name $FunctionAppName --plan $appServicePlanId --resource-group $FunctionAppResourceGroupName --storage-account $FunctionAppStorageAccountName --runtime $FunctionAppRuntime --functions-version 3 --disable-app-insights --tags ${ResourceTags}
    $functionAppId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id
}

# Enforce HTTPS
Invoke-Executable az functionapp update --ids $functionAppId --set httpsOnly=true

# Disable FTPS
Invoke-Executable az functionapp config set --ids $functionAppId --ftps-state Disabled

# Set number of instances
Invoke-Executable az functionapp config set --ids $functionAppId --number-of-workers $FunctionAppNumberOfInstances

# Set Always On
Invoke-Executable az functionapp config set --always-on $FunctionAppAlwaysOn --ids $functionAppId

# Set some basic configs (including vnet route all)
Invoke-Executable az functionapp config appsettings set --ids $functionAppId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"

#  Create diagnostics settings
Invoke-Executable az monitor diagnostic-settings create --resource $functionAppId --name $FunctionAppDiagnosticsName --workspace $LogAnalyticsWorkspaceName --logs "[{ 'category': 'FunctionAppLogs', 'enabled': true } ]".Replace("'", '\"') --metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

# Create & Assign WebApp identity to AppService
Invoke-Executable az functionapp identity assign --ids $functionAppId

# By default a staging slot will be added
if ($EnableFunctionAppDeploymentSlot)
{
    Invoke-Executable az functionapp deployment slot create --resource-group $FunctionAppResourceGroupName --name $FunctionAppName  --slot $FunctionAppDeploymentSlotName
    $functionAppStagingId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName --slot $FunctionAppDeploymentSlotName | ConvertFrom-Json).id
    Invoke-Executable az functionapp config set --ids $functionAppStagingId --ftps-state Disabled --slot $FunctionAppDeploymentSlotName
    Invoke-Executable az functionapp config set --ids $functionAppStagingId --number-of-workers $FunctionAppNumberOfInstances --slot $FunctionAppDeploymentSlotName
    Invoke-Executable az functionapp config appsettings set --ids $functionAppStagingId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"
    Invoke-Executable az functionapp identity assign --ids $functionAppStagingId --slot $FunctionAppDeploymentSlotName

    if ($DisablePublicAccessForFunctionAppDeploymentSlot)
    {
        #todo: fix this with common function
        $accessRestrictionRuleName = 'DisablePublicAccess'
        $restrictions = Invoke-Executable az functionapp config access-restriction show --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --slot $FunctionAppDeploymentSlotName | ConvertFrom-Json

        if (!($restrictions.scmIpSecurityRestrictions | Where-Object { $_.Name -eq $accessRestrictionRuleName }))
        {
            Invoke-Executable az functionapp config access-restriction add --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --action Deny --priority 100000 --description $FunctionAppName --rule-name $accessRestrictionRuleName --ip-address '0.0.0.0/0' --scm-site $true --slot $FunctionAppDeploymentSlotName
        }

        if (!($restrictions.ipSecurityRestrictions | Where-Object { $_.Name -eq $accessRestrictionRuleName }))
        {
            Invoke-Executable az functionapp config access-restriction add --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --action Deny --priority 100000 --description $FunctionAppName --rule-name $accessRestrictionRuleName --ip-address '0.0.0.0/0' --scm-site $false --slot $FunctionAppDeploymentSlotName
        }
    }
}

# VNET Whitelisting
if ($GatewayVnetResourceGroupName -and $GatewayVnetName -and $GatewaySubnetName)
{
    Write-Host "VNET Whitelisting is desired. Adding the needed components."
    # Fetch the Subnet ID where the Application Resides in
    $gatewaySubnetId = (Invoke-Executable az network vnet subnet show --resource-group $GatewayVnetResourceGroupName --name $GatewaySubnetName --vnet-name $GatewayVnetName | ConvertFrom-Json).id

    # Make sure the service endpoint is enabled for the subnet (for internal routing)
    Set-SubnetServiceEndpoint -SubnetResourceId $gatewaySubnetId -ServiceEndpointServiceIdentifier "Microsoft.Web"

    # Allow the Gateway Subnet to this AppService through a vnet-rule
    $firewallRuleName = ToMd5Hash -InputString "$($GatewayVnetName)_$($GatewaySubnetName)_allow"
    if (!((az functionapp config access-restriction show --resource-group $FunctionAppResourceGroupName --name $FunctionAppName | ConvertFrom-Json).ipSecurityRestrictions | Where-Object { $_.name -eq $firewallRuleName }))
    {
        Invoke-Executable az functionapp config access-restriction add --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --rule-name $firewallRuleName --action Allow --subnet $gatewaySubnetId --priority $GatewayWhitelistRulePriority --scm-site $false
    }

    if (!((az functionapp config access-restriction show --resource-group $FunctionAppResourceGroupName --name $FunctionAppName | ConvertFrom-Json).scmIpSecurityRestrictions | Where-Object { $_.name -eq $firewallRuleName }))
    {
        Invoke-Executable az functionapp config access-restriction add --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --rule-name $firewallRuleName --action Allow --subnet $gatewaySubnetId --priority $GatewayWhitelistRulePriority --scm-site $true
    }
}

# Add private endpoint & Setup Private DNS
if ($FunctionAppPrivateEndpointVnetResourceGroupName -and $FunctionAppPrivateEndpointVnetName -and $FunctionAppPrivateEndpointSubnetName -and $DNSZoneResourceGroupName -and $FunctionAppPrivateDnsZoneName)
{
    Write-Host "A private endpoint is desired. Adding the needed components."
    # Fetch needed information
    $vnetId = (Invoke-Executable az network vnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointSubnetName --vnet-name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
    $functionAppPrivateEndpointName = "$($FunctionAppName)-pvtfunc"

    # Add private endpoint & Setup Private DNS
    Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $functionAppPrivateEndpointSubnetId -PrivateEndpointName $functionAppPrivateEndpointName -PrivateEndpointResourceGroupName $FunctionAppResourceGroupName -TargetResourceId $functionAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $FunctionAppPrivateDnsZoneName -PrivateDnsLinkName "$($FunctionAppPrivateEndpointVnetName)-appservice"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet