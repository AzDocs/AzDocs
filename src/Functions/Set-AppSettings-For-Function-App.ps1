[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string[]] $FunctionAppAppSettings,
    [Parameter()][string] $FunctionAppDeploymentSlotName,
    [Parameter()][bool] $EnableDeploymentSetting = $false,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots) {
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

$optionalParameters = @()
if ($FunctionAppDeploymentSlotName) {
    $optionalParameters += "--slot", "$FunctionAppDeploymentSlotName"
}

if ($EnableDeploymentSetting) {
    Invoke-Executable az functionapp config appsettings set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --slot-settings @FunctionAppAppSettings @optionalParameters

    foreach ($availableSlot in $availableSlots) {
        Invoke-Executable az functionapp config appsettings set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --slot-settings @FunctionAppAppSettings --slot $availableSlot.name
    }
}
else {
    Invoke-Executable az functionapp config appsettings set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --settings @FunctionAppAppSettings @optionalParameters

    foreach ($availableSlot in $availableSlots) {
        Invoke-Executable az functionapp config appsettings set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --settings @FunctionAppAppSettings --slot $availableSlot.name
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet