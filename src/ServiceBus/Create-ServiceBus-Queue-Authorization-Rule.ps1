[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter(Mandatory)][string] $QueueName,
    [Parameter(Mandatory)][string] $RuleName,
    [Parameter()][boolean] $GrantSend = $false,
    [Parameter()][boolean] $GrantListen = $false,
    [Parameter()][boolean] $GrantManage = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if (!$GrantSend -and !$GrantListen -and !$GrantManage)
{
    throw 'Error: At least one permission should be granted!'
}

$optionalParameters = @()
if ($GrantSend -or $GrantManage)
{
    $optionalParameters += 'Send'
}
if ($GrantListen -or $GrantManage)
{
    $optionalParameters += 'Listen'
}
if ($GrantManage)
{
    $optionalParameters += 'Manage'
}

Write-Host 'Permissions to grant'
Write-Host $optionalParameters
$serviceBusNamespace = Invoke-Executable -AllowToFail az servicebus namespace show --resource-group $ServiceBusNamespaceResourceGroupName --name $ServiceBusNamespaceName | ConvertFrom-Json

if (!$serviceBusNamespace -or $serviceBusNamespace.provisioningState -ne 'Succeeded')
{
    throw "ServiceBus was not found: $ServiceBusNamespaceResourceGroupName - $ServiceBusNamespaceName"
}

$queueInformation = Invoke-Executable -AllowToFail az servicebus queue show --resource-group $ServiceBusNamespaceResourceGroupName --namespace $ServiceBusNamespaceName --name $QueueName | ConvertFrom-Json
if (!$queueInformation)
{
    throw "Queue was not found: $ServiceBusNamespaceResourceGroupName - $ServiceBusNamespaceName - $QueueName"
}

Write-Host 'Queue exists. Dispatch update command.'
$authorizationRule = Invoke-Executable -AllowToFail az servicebus queue authorization-rule show --resource-group $ServiceBusNamespaceResourceGroupName --namespace-name $ServiceBusNamespaceName --queue-name $QueueName --name $RuleName | ConvertFrom-Json
if (!$authorizationRule)
{
    Write-Host "Authorization Rule was not found: $ServiceBusNamespaceResourceGroupName - $ServiceBusNamespaceName - $QueueName - $RuleName"
    Invoke-Executable az servicebus queue authorization-rule create --resource-group $ServiceBusNamespaceResourceGroupName --namespace-name $ServiceBusNamespaceName --queue-name $QueueName --name $RuleName --rights @optionalParameters
}
else
{
    Write-Host "Authorization Rule found, updating: $ServiceBusNamespaceResourceGroupName - $ServiceBusNamespaceName - $QueueName - $RuleName"
    Invoke-Executable az servicebus queue authorization-rule update --resource-group $ServiceBusNamespaceResourceGroupName --namespace-name $ServiceBusNamespaceName --queue-name $QueueName --name $RuleName --rights @optionalParameters
}

Write-Footer -ScopedPSCmdlet $PSCmdlet