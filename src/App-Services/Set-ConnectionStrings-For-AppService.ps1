[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceConnectionStringsInJson,
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

foreach($AppServiceConnectionString in ($AppServiceConnectionStringsInJson | ConvertFrom-Json))
{
    # Updated defined slot
    Invoke-Executable az webapp config connection-string set --resource-group $AppServiceResourceGroupName --name $AppServiceName --connection-string-type $AppServiceConnectionString.type --settings $AppServiceConnectionString.name=$AppServiceConnectionString.value @optionalParameters

    # Update slots
    foreach($availableSlot in $availableSlots)
    {
        Invoke-Executable az webapp config connection-string set --resource-group $AppServiceResourceGroupName --name $AppServiceName --connection-string-type $AppServiceConnectionString.type --settings $AppServiceConnectionString.name=$AppServiceConnectionString.value --slot $availableSlot.name
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet