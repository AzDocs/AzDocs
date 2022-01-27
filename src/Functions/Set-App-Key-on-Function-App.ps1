[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppAppKeyName,
    [Parameter()][string] $FunctionAppAppKeyValue,
    [Parameter()][ValidateSet("functionKeys", "masterKey", "systemKey")][string] $FunctionAppAppKeyType = "functionKeys",
    [Parameter()][string] $FunctionAppDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false,
    [Parameter()][int] $RetryApplyToAllSlotsCount = 3
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

function Invoke-WithRetry {
    param(
        [Parameter(Mandatory)][string] $ExecutableLiteralPath,
        [Parameter(ValueFromRemainingArguments)] $ExecutableArguments,
        [Parameter()][int] $retries = 3
    )

    $retryCount = 0
    $success = $false
    while ($retryCount++ -lt $retries -and (-not $success))
    {
        try 
        {
            $result = Invoke-Executable -ExecutableLiteralPath $ExecutableLiteralPath @ExecutableArguments
            $success = $true
        }
        catch
        {
            Start-Sleep -Seconds (($retryCount + 1) * 5)
        }
    }

    $success
    $result
}

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

$optionalParameters = @()
if ($FunctionAppDeploymentSlotName)
{
    $optionalParameters += "--slot", "$FunctionAppDeploymentSlotName"
}

if ($FunctionAppAppKeyValue)
{
    $optionalParameters += "--key-value", "$FunctionAppAppKeyValue"
}

$setKeyResult = Invoke-Executable az functionapp keys set --key-name $FunctionAppAppKeyName --key-type $FunctionAppAppKeyType --name $FunctionAppName --resource-group $FunctionAppResourceGroupName @optionalSlotParameter @optionalParameters | ConvertFrom-Json
$keyValue = $setKeyResult.properties.value

Write-Output $keyValue

foreach($availableSlot in $availableSlots)
{
    # Slot keys can not be modified if slot is stopped
    $stopSlot = $false
    if ($availableSlot.State -eq "Stopped")
    {
        $stopSlot = $true
        Invoke-Executable az functionapp start --name $FunctionAppName --resource-group $FunctionAppResourceGroupName --slot $availableSlot.name
        Start-Sleep -Seconds 1
    }

    $success = (Invoke-WithRetry -retries $RetryApplyToAllSlotsCount az functionapp keys set --key-name $FunctionAppAppKeyName --key-type $FunctionAppAppKeyType --name $FunctionAppName --resource-group $FunctionAppResourceGroupName --slot $availableSlot.name --key-value $keyValue)[0]

    if ($stopSlot) 
    {
        Invoke-Executable az functionapp stop --name $FunctionAppName --resource-group $FunctionAppResourceGroupName --slot $availableSlot.name
    }

    if (-not $success)
    {
        throw "Failed to apply key to $($availableSlot.name) slot"
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet