[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ContainerName,
    [Parameter(Mandatory)][string] $ContainerResourceGroupName,
    [Parameter(Mandatory)][int] $ContainerCpuCount,
    [Parameter(Mandatory)][int] $ContainerMemoryInGb,
    [Parameter(Mandatory)][string] $ContainerOs,
    [Parameter(Mandatory)][string] $ContainerPorts,
    [Parameter(Mandatory)][string] $ContainerImageName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $ContainerVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $ContainerVnetResourceGroupName,
    [Parameter(Mandatory)][string] $ContainerSubnetName,
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
    [Parameter()][string] $LogAnalyticsWorkspaceKey
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$vnetId = (Invoke-Executable az network vnet show --resource-group $ContainerVnetResourceGroupName --name $ContainerVnetName | ConvertFrom-Json).id
$containerSubnetId = (Invoke-Executable az network vnet subnet show --resource-group $ContainerVnetResourceGroupName --name $ContainerSubnetName --vnet-name $ContainerVnetName | ConvertFrom-Json).id
$ContainerName = $ContainerName.ToLower()

$scriptArguments = "--name", "$ContainerName", "--resource-group", "$ContainerResourceGroupName", "--ip-address", "Private", "--os-type", "$ContainerOs", "--cpu", $ContainerCpuCount, "--memory", $ContainerMemoryInGb, "--image", "$ContainerImageName", "--vnet", "$vnetId", "--subnet", "$containerSubnetId"

if ($ContainerPorts) {
    # Add the ports (nasty hack)
    $scriptArguments += "--ports"
    foreach ($port in ($ContainerPorts -split ' ')) {
        $scriptArguments += $port
    }
}

if ($ImageRegistryLoginServer) {
    $scriptArguments += "--registry-login-server", "$ImageRegistryLoginServer"
}

if ($ImageRegistryUserName) {
    $scriptArguments += "--registry-username", "$ImageRegistryUserName"
}

if ($ImageRegistryPassword) {
    $scriptArguments += "--registry-password", "$ImageRegistryPassword"
}

if ($ContainerEnvironmentVariables) {
    $scriptArguments += "--environment-variables", $ContainerEnvironmentVariables -split $ContainerEnvironmentVariablesDelimiter
}

if ($StorageAccountFileShareName -and $FileShareStorageAccountName -and $FileShareStorageAccountResourceGroupName -and $StorageAccountFileShareMountPath) {
    $storageKey = Invoke-Executable az storage account keys list --resource-group $FileShareStorageAccountResourceGroupName --account-name $FileShareStorageAccountName --query=[0].value --output tsv
    $scriptArguments += "--azure-file-volume-share-name", "$StorageAccountFileShareName", "--azure-file-volume-account-name", "$FileShareStorageAccountName", "--azure-file-volume-account-key", "$storageKey", "--azure-file-volume-mount-path", "$StorageAccountFileShareMountPath"
}

if ($LogAnalyticsWorkspaceId -and $LogAnalyticsWorkspaceKey) {
    $scriptArguments += '--log-analytics-workspace', "$LogAnalyticsWorkspaceId"
    $scriptArguments += '--log-analytics-workspace-key', "$LogAnalyticsWorkspaceKey"
}

Write-Host "Script Arguments: $scriptArguments"

Invoke-Executable az container create @scriptArguments

Write-Footer -ScopedPSCmdlet $PSCmdlet