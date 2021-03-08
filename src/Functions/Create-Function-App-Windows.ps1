[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $FunctionAppPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $FunctionAppPrivateEndpointVnetName,
    [Parameter(Mandatory)][string] $FunctionAppPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppStorageAccountName,
    [Parameter(Mandatory)][string] $FunctionAppDiagnosticsName,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceName,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $FunctionAppPrivateDnsZoneName = "privatelink.azurewebsites.net",
    [Alias("AlwaysOn")]
    [Parameter(Mandatory)][string] $FunctionAppAlwaysOn,
    [Parameter(Mandatory)][string] $FUNCTIONS_EXTENSION_VERSION,
    [Parameter(Mandatory)][string] $ASPNETCORE_ENVIRONMENT,
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableFunctionAppDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $FunctionAppDeploymentSlotName = "staging", 
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForFunctionAppDeploymentSlot = $true,

    # Optional remaining arguments. This is a fix for being able to pass down parameters in an easy way using @PSBoundParameters in Create-Function-App-with-App-Service-Plan-Linux.ps1
    [Parameter(ValueFromRemainingArguments)][string[]] $Remaining
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetId = (Invoke-Executable az network vnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
$functionAppPrivateEndpointSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $FunctionAppPrivateEndpointVnetResourceGroupName --name $FunctionAppPrivateEndpointSubnetName --vnet-name $FunctionAppPrivateEndpointVnetName | ConvertFrom-Json).id
$functionAppPrivateEndpointName = "$($FunctionAppName)-pvtfunc"

# Fetch AppService Plan ID
$appServicePlanId = (Invoke-Executable az appservice plan show --resource-group $AppServicePlanResourceGroupName --name $AppServicePlanName | ConvertFrom-Json).id

# Fetch the ID from the FunctionApp
$functionAppId = (Invoke-Executable -AllowToFail az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id

#TODO: az functionapp create is not idempotent, therefore the following fix. For more information, see https://github.com/Azure/azure-cli/issues/11863 
if (!$functionAppId)
{
    # Create FunctionApp
    Invoke-Executable az functionapp create --name $FunctionAppName --plan $appServicePlanId --resource-group $FunctionAppResourceGroupName --storage-account $FunctionAppStorageAccountName --runtime dotnet --functions-version 3 --disable-app-insights --tags ${ResourceTags}
    $functionAppId = (Invoke-Executable az functionapp show --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json).id
}

# Disable HTTPS
Invoke-Executable az functionapp update --ids $functionAppId --set httpsOnly=true

# Disable FTPS
Invoke-Executable az functionapp config set --ids $functionAppId --ftps-state Disabled

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
    Invoke-Executable az functionapp config appsettings set --ids $functionAppStagingId --settings "ASPNETCORE_ENVIRONMENT=$($ASPNETCORE_ENVIRONMENT)" "FUNCTIONS_EXTENSION_VERSION=$($FUNCTIONS_EXTENSION_VERSION)"
    Invoke-Executable az functionapp identity assign --ids $functionAppStagingId --slot $FunctionAppDeploymentSlotName

    if ($DisablePublicAccessForFunctionAppDeploymentSlot)
    {
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

# Add private endpoint & Setup Private DNS
Add-PrivateEndpoint -PrivateEndpointVnetId $vnetId -PrivateEndpointSubnetId $functionAppPrivateEndpointSubnetId -PrivateEndpointName $functionAppPrivateEndpointName -PrivateEndpointResourceGroupName $FunctionAppResourceGroupName -TargetResourceId $functionAppId -PrivateEndpointGroupId sites -DNSZoneResourceGroupName $DNSZoneResourceGroupName -PrivateDnsZoneName $FunctionAppPrivateDnsZoneName -PrivateDnsLinkName "$($FunctionAppPrivateEndpointVnetName)-appservice"

Write-Footer -ScopedPSCmdlet $PSCmdlet