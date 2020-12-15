[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $ContainerName,

    [Parameter(Mandatory)]
    [string] $ContainerResourceGroupName,

    [Parameter(Mandatory)]
    [int] $ContainerCpuCount,

    [Parameter(Mandatory)]
    [int] $ContainerMemoryInGb,

    [Parameter(Mandatory)]
    [string] $ContainerOs,

    [Parameter(Mandatory)]
    [string] $ContainerPorts,

    [Parameter(Mandatory)]
    [string] $ContainerImageName,

    [Parameter(Mandatory)]
    [string] $VnetName,

    [Parameter(Mandatory)]
    [string] $VnetResourceGroupName,

    [Parameter(Mandatory)]
    [string] $ContainerSubnetName,

    [Parameter()]
    [string] $RegistryLoginServer,

    [Parameter()]
    [string] $RegistryUserName,

    [Parameter()]
    [string] $RegistryPassword,

    [Parameter()]
    [string] $ContainerEnvironmentVariables,

    [Parameter()]
    [string] $ContainerEnvironmentVariablesDelimiter = ";",

    [Parameter()]
    [string] $AzureFileShareName,

    [Parameter()]
    [string] $AzureFileShareStorageAccountName,

    [Parameter()]
    [string] $AzureFileShareStorageAccountResourceGroupName,

    [Parameter()]
    [string] $AzureFileShareMountPath,

    [Parameter()]
    [String] $logAnalyticsWorkspaceId,

    [Parameter()]
    [String] $logAnalyticsWorkspaceKey
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

$vnetId = (Invoke-Executable az network vnet show -g $VnetResourceGroupName -n $VnetName | ConvertFrom-Json).id
$containerSubnetId = (Invoke-Executable az network vnet subnet show -g $VnetResourceGroupName -n $ContainerSubnetName --vnet-name $VnetName | ConvertFrom-Json).id
$ContainerName = $ContainerName.ToLower()

$scriptArguments = "--name", "$ContainerName", "--resource-group", "$ContainerResourceGroupName", "--ip-address", "Private", "--os-type", "$ContainerOs", "--cpu", $ContainerCpuCount, "--memory", $ContainerMemoryInGb, "--image", "$ContainerImageName", "--vnet", "$vnetId", "--subnet", "$containerSubnetId"

if ($ContainerPorts) {
    # Add the ports (nasty hack)
    $scriptArguments += "--ports"
    foreach ($port in ($ContainerPorts -split ' ')) {
        $scriptArguments += $port
    }
}

if ($RegistryLoginServer) {
    $scriptArguments += "--registry-login-server", "$RegistryLoginServer"
}

if ($RegistryLoginServer) {
    $scriptArguments += "--registry-username", "$RegistryUserName"
}

if ($RegistryLoginServer) {
    $scriptArguments += "--registry-password", "$RegistryPassword"
}

if ($ContainerEnvironmentVariables) {
    $scriptArguments += "--environment-variables", $ContainerEnvironmentVariables -split $ContainerEnvironmentVariablesDelimiter
}

if ($AzureFileShareName -and $AzureFileShareStorageAccountName -and $AzureFileShareStorageAccountResourceGroupName -and $AzureFileShareMountPath) {
    $storageKey = Invoke-Executable az storage account keys list -g $AzureFileShareStorageAccountResourceGroupName -n $AzureFileShareStorageAccountName --query=[0].value --output tsv
    $scriptArguments += "--azure-file-volume-share-name", "$AzureFileShareName", "--azure-file-volume-account-name", "$AzureFileShareStorageAccountName", "--azure-file-volume-account-key", "$storageKey", "--azure-file-volume-mount-path", "$AzureFileShareMountPath"
}

if ($logAnalyticsWorkspaceId) {
    $scriptArguments += '--log-analytics-workspace', "$logAnalyticsWorkspaceId"
    if ($logAnalyticsWorkspaceKey) {
        $scriptArguments += '--log-analytics-workspace-key', "$logAnalyticsWorkspaceKey"
    }
}

Write-Host "Script Arguments: $scriptArguments"

Invoke-Executable az container create @scriptArguments