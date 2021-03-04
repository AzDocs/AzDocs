[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $AppServicePrivateEndpointVnetResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $AppServicePrivateEndpointVnetName,
    [Alias("ApplicationPrivateEndpointSubnetName")]
    [Parameter(Mandatory)][string] $AppServicePrivateEndpointSubnetName,
    [Parameter(Mandatory)][string] $AppServicePlanName,
    [Parameter(Mandatory)][string] $AppServicePlanResourceGroupName,
    [Parameter(Mandatory)][string] $AppServicePlanSkuName,
    [Parameter(Mandatory)][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceDiagnosticsName,
    [Alias("LogAnalyticsWorkspaceName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $AppServicePrivateDnsZoneName = "privatelink.azurewebsites.net",
    [Parameter()][string] $AppServiceRunTime,
    
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableAppServiceDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $AppServiceDeploymentSlotName = 'staging',
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForAppServiceDeploymentSlot = $true
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\PrivateEndpoint-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

# Create AppServicePlan
& "$PSScriptRoot\Create-App-Service-Plan-Windows.ps1" -AppServicePlanName $AppServicePlanName -AppServicePlanResourceGroupName $AppServicePlanResourceGroupName -AppServicePlanSkuName $AppServicePlanSkuName -ResourceTags ${ResourceTags}

# Create AppService
& "$PSScriptRoot\Create-Web-App-Windows.ps1" @PSBoundParameters

Write-Footer