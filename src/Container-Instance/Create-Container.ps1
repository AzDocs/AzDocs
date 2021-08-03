[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerName,
    [Parameter(Mandatory)][string] $ContainerResourceGroupName,
    [Parameter(Mandatory)][int] $ContainerCpuCount,
    [Parameter(Mandatory)][int] $ContainerMemoryInGb,
    [Parameter(Mandatory)][string][ValidateSet("Linux", "Windows")] $ContainerOs,
    [Parameter(Mandatory)][string] $ContainerPorts,
    [Parameter(Mandatory)][string] $ContainerImageName,

    # Networking
    [Alias("VnetName")]
    [Parameter()][string] $ContainerVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter()][string] $ContainerVnetResourceGroupName,
    [Parameter()][string] $ContainerSubnetName,
    [Parameter()][string][ValidateSet("Private", "Public")] $ContainerIpAddressType = "Private",
    
    [Alias("RegistryLoginServer")]
    [Parameter()][string] $ImageRegistryLoginServer,
    [Alias("RegistryUserName")]
    [Parameter()][string] $ImageRegistryUserName,
    [Alias("RegistryPassword")]
    [Parameter()][string] $ImageRegistryPassword,
    [Parameter()][string] $ContainerEnvironmentVariables,
    [Parameter()][string] $ContainerEnvironmentVariablesDelimiter = ";",
    [Alias("AzureFileShareName")]
    [Parameter()][string] $StorageAccountFileShareName,
    [Alias("AzureFileShareStorageAccountName")]
    [Parameter()][string] $FileShareStorageAccountName,
    [Alias("AzureFileShareStorageAccountResourceGroupName")]
    [Parameter()][string] $FileShareStorageAccountResourceGroupName,
    [Alias("AzureFileShareMountPath")]
    [Parameter()][string] $StorageAccountFileShareMountPath,
    [Parameter()][Guid] $LogAnalyticsWorkspaceId,
    [Parameter()][string] $LogAnalyticsWorkspaceKey,

    # Forcefully agree to this resource to be spun up to be publicly available
    [Parameter()][switch] $ForcePublic
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$ContainerName = $ContainerName.ToLower()
$optionalParameters = @()
if ($ContainerIpAddressType -eq "Private") {
    if (!$ContainerVnetName -or !$ContainerVnetResourceGroupName -or !$ContainerSubnetName) {
        throw 'You have specified the container to be Private. Make sure to provide the values for ContainerVnetName, ContainerVnetResourceGroupName and ContainerSubnetName.'
    }

    $vnetId = (Invoke-Executable az network vnet show --resource-group $ContainerVnetResourceGroupName --name $ContainerVnetName | ConvertFrom-Json).id
    $containerSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ContainerVnetResourceGroupName --name $ContainerSubnetName --vnet-name $ContainerVnetName | ConvertFrom-Json).id
    $optionalParameters += "--vnet", "$vnetId", "--subnet", "$containerSubnetId"
}
else {
    # Check if we are making this resource public intentionally
    Assert-IntentionallyCreatedPublicResource -ForcePublic $ForcePublic
}

if ($ContainerPorts) {
    # Add the ports (nasty hack)
    $optionalParameters += "--ports"
    foreach ($port in ($ContainerPorts -split ' ')) {
        $optionalParameters += $port
    }
}

if ($ImageRegistryLoginServer) {
    $optionalParameters += "--registry-login-server", "$ImageRegistryLoginServer"
}

if ($ImageRegistryUserName) {
    $optionalParameters += "--registry-username", "$ImageRegistryUserName"
}

if ($ImageRegistryPassword) {
    $optionalParameters += "--registry-password", "$ImageRegistryPassword"
}

if ($ContainerEnvironmentVariables) {
    $optionalParameters += "--environment-variables", $ContainerEnvironmentVariables -split $ContainerEnvironmentVariablesDelimiter
}

if ($StorageAccountFileShareName -and $FileShareStorageAccountName -and $FileShareStorageAccountResourceGroupName -and $StorageAccountFileShareMountPath) {
    $storageKey = Invoke-Executable az storage account keys list --resource-group $FileShareStorageAccountResourceGroupName --account-name $FileShareStorageAccountName --query=[0].value --output tsv
    $optionalParameters += "--azure-file-volume-share-name", "$StorageAccountFileShareName", "--azure-file-volume-account-name", "$FileShareStorageAccountName", "--azure-file-volume-account-key", "$storageKey", "--azure-file-volume-mount-path", "$StorageAccountFileShareMountPath"
}

if ($LogAnalyticsWorkspaceId -and $LogAnalyticsWorkspaceKey) {
    $optionalParameters += '--log-analytics-workspace', "$LogAnalyticsWorkspaceId"
    $optionalParameters += '--log-analytics-workspace-key', "$LogAnalyticsWorkspaceKey"
}

# TODO: Add managed identity when it's GA. https://docs.microsoft.com/en-us/azure/container-instances/container-instances-managed-identity
# Create container instance
Invoke-Executable az container create --name $ContainerName --resource-group $ContainerResourceGroupName --ip-address $ContainerIpAddressType --os-type $ContainerOS --cpu $ContainerCpuCount --memory $ContainerMemoryInGB --image $ContainerImageName @optionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet