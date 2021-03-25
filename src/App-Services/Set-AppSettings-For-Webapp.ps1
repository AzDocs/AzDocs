[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceAppSettings,
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

Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName --settings $AppServiceAppSettings @optionalParameters

foreach($availableSlot in $availableSlots)
{
    Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName --settings $AppServiceAppSettings --slot $availableSlot.name
}

Write-Footer -ScopedPSCmdlet $PSCmdlet