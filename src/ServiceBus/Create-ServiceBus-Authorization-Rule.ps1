[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceBusAuthorizationRuleName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceName,
    [Parameter(Mandatory)][string] $ServiceBusNamespaceResourceGroupName,
    [Parameter(Mandatory)][ValidateSet("Listen", "Manage", "Send")][string[]] $ServiceBusAuthRights,
    [Parameter][string] $ServiceBusQueueName,
    [Parameter][string] $ServiceBusTopicName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$ServiceBusAuthRightsConcat = $ServiceBusAuthRights -join ' '

if ($ServiceBusQueueName)
{
    Invoke-Executable az servicebus queue authorization-rule create --resource-group $ServiceBusNamespaceResourceGroupName --namespace-name $ServiceBusNamespaceName --queue-name $ServiceBusQueueName --name $ServiceBusAuthorizationRuleName --rights $ServiceBusAuthRightsConcat
}
elseif ($ServiceBusTopicName)
{
    Invoke-Executable az servicebus topic authorization-rule create --resource-group $ServiceBusNamespaceResourceGroupName --namespace-name $ServiceBusNamespaceName --topic-name $ServiceBusTopicName --name $ServiceBusAuthorizationRuleName --rights $ServiceBusAuthRightsConcat
}
else
{
    Invoke-Executable az servicebus namespace authorization-rule create --resource-group $ServiceBusNamespaceResourceGroupName --namespace-name $ServiceBusNamespaceName --name $ServiceBusAuthorizationRuleName --rights $ServiceBusAuthRightsConcat
}


Write-Footer -ScopedPSCmdlet $PSCmdlet