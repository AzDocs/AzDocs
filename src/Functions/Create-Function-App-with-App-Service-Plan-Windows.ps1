[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $FunctionAppPrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $FunctionAppPrivateEndpointVnetName,
    [Parameter(Mandatory)][string] $FunctionAppPrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $AppServicePlanSkuName,
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
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForFunctionAppDeploymentSlot = $true
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\PrivateEndpoint-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

# Create App Service Plan
& "$PSScriptRoot\..\App-Services\Create-App-Service-Plan-Windows.ps1" -AppServicePlanName $AppServicePlanName -AppServicePlanResourceGroupName $AppServicePlanResourceGroupName -AppServicePlanSkuName $AppServicePlanSkuName -ResourceTags ${ResourceTags}

# Create Function App
& "$PSScriptRoot\Create-Function-App-Windows.ps1" @PSBoundParameters

Write-Footer