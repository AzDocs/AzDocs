[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceConnectionString,
    [Parameter(Mandatory)][ValidateSet("ApiHub", "Custom", "DocDb", "EventHub", "MySql", "NotificationHub", "PostgreSQL", "RedisCache", "SQLAzure", "SQLServer", "ServiceBus")][string] $AppServiceConnectionStringType,
    [Parameter()][string] $AppServiceDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json
}

$optionalParameters = @()
if ($AppServiceDeploymentSlotName)
{
    $optionalParameters += "--slot", "$AppServiceDeploymentSlotName"
}

Invoke-Executable az webapp config connection-string set --resource-group $AppServiceResourceGroupName --name $AppServiceName --connection-string-type $AppServiceConnectionStringType --settings $AppServiceConnectionString @optionalParameters

foreach($availableSlot in $availableSlots)
{
    Invoke-Executable az webapp config connection-string set --resource-group $AppServiceResourceGroupName --name $AppServiceName --connection-string-type $AppServiceConnectionStringType --settings $AppServiceConnectionString --slot $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet