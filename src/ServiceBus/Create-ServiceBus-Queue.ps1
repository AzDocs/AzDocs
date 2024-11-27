[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter(Mandatory)][string] $QueueName,

    [Parameter()][ValidateSet(1024, 10240, 2048, 20480, 3072, 4096, 40960, 5120, 81920)][int] $MaxSize = 5120,
    [Parameter()][ValidateRange(0, 100)][int] $MaxDeliveryCount = 10,

    # Enable features 
    [Parameter()][boolean] $EnableBatchedOperations = $true,
    [Parameter()][boolean] $EnableDeadletteringOnMessageExpiration = $true,
    [Parameter()][boolean] $EnablePartitioning = $false,
    [Parameter()][boolean] $EnableSessions = $true
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParameters = @()
$optionalParameters += '--enable-batched-operations', "$EnableBatchedOperations"
$optionalParameters += '--enable-dead-lettering-on-message-expiration', "$EnableDeadletteringOnMessageExpiration"
$optionalParameters += '--enable-partitioning', "$EnablePartitioning"
$optionalParameters += '--enable-session', "$EnableSessions"

Write-Host 'Optional parameters'
Write-Host $optionalParameters
$serviceBusNamespace = Invoke-Executable az servicebus namespace show --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName | ConvertFrom-Json

if (!$serviceBusNamespace -or $serviceBusNamespace.provisioningState -ne 'Succeeded')
{
    throw "ServiceBus was not found: $ServiceBusNamespaceResourceGroupName - $ServiceBusNamespaceName"
}

$queueInformation = Invoke-Executable -AllowToFail az servicebus queue show --resource-group $ServiceBusNamespaceResourceGroupName --namespace $ServiceBusNamespaceName --name $QueueName | ConvertFrom-Json
if ($queueInformation)
{
    Write-Host 'Queue exists. Dispatch update command.'
    Invoke-Executable az servicebus queue update --resource-group $ServiceBusNamespaceResourceGroupName --namespace $ServiceBusNamespaceName --name $QueueName --max-size $MaxSize --max-delivery-count $MaxDeliveryCount @optionalParameters
}
else
{
    Write-Host 'Queue does not exist. Dispatch create command'
    Invoke-Executable az servicebus queue create --resource-group $ServiceBusNamespaceResourceGroupName --namespace $ServiceBusNamespaceName --name $QueueName --max-size $MaxSize --max-delivery-count $MaxDeliveryCount @optionalParameters
}

Write-Footer -ScopedPSCmdlet $PSCmdlet