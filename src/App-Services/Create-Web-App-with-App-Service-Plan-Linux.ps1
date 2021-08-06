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
    [Parameter(Mandatory, ParameterSetName = 'default')][Parameter(Mandatory, ParameterSetName = 'DeploymentSlot')][string] $AppServiceRunTime,
    [Alias("LogAnalyticsWorkspaceName")]
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory)][string] $DNSZoneResourceGroupName,
    [Alias("PrivateDnsZoneName")]
    [Parameter()][string] $AppServicePrivateDnsZoneName = "privatelink.azurewebsites.net",
    [Parameter()][string] $AppServicePlanNumberOfWorkerInstances = 3,
    [Parameter()][string] $AppServiceNumberOfInstances = 2,
    
    [Parameter(ParameterSetName = 'DeploymentSlot')][switch] $EnableAppServiceDeploymentSlot,
    [Parameter(ParameterSetName = 'DeploymentSlot')][string] $AppServiceDeploymentSlotName = 'staging',
    [Parameter(ParameterSetName = 'DeploymentSlot')][bool] $DisablePublicAccessForAppServiceDeploymentSlot = $true,

    # Use container image name with optional tag for example thelastpickle/cassandra-reaper:latest
    [Parameter(Mandatory, ParameterSetName = 'Container')][string] $ContainerImageName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Warning 'This script is deprecated. Please use the Create-Web-App.ps1 and the Create-App-Service-Plan-Linux.ps1 instead.'
Write-Host "##vso[task.complete result=SucceededWithIssues;]"

# Create AppServicePlan
& "$PSScriptRoot\Create-App-Service-Plan-Linux.ps1" -AppServicePlanName $AppServicePlanName -AppServicePlanResourceGroupName $AppServicePlanResourceGroupName -AppServicePlanSkuName $AppServicePlanSkuName -AppServicePlanNumberOfWorkerInstances $AppServicePlanNumberOfWorkerInstances -ResourceTags ${ResourceTags}

# Create AppService
& "$PSScriptRoot\Create-Web-App.ps1" @PSBoundParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet