[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $FunctionAppConnectionStringsInJson,
    [Parameter()][string] $FunctionAppDeploymentSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ApplyToAllSlots)
{
    $availableSlots = Invoke-Executable -AllowToFail az functionapp deployment slot list --name $FunctionAppName --resource-group $FunctionAppResourceGroupName | ConvertFrom-Json
}

$optionalParameters = @()
if ($FunctionAppDeploymentSlotName)
{
    $optionalParameters += "--slot", "$FunctionAppDeploymentSlotName"
}

foreach($FunctionAppConnectionString in ($FunctionAppConnectionStringsInJson | ConvertFrom-Json))
{
    $connectionStringKeyValuePair = "$($FunctionAppConnectionString.name)=`"$($FunctionAppConnectionString.value)`""
    
    # YES WE USE az webapp FOR A FUNCTION --> https://github.com/Azure/azure-cli/issues/8882

    # Updated defined slot
    Invoke-Executable az webapp config connection-string set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --connection-string-type $($FunctionAppConnectionString.type) --settings $connectionStringKeyValuePair @optionalParameters

    # Update slots
    foreach($availableSlot in $availableSlots)
    {
        Invoke-Executable az webapp config connection-string set --resource-group $FunctionAppResourceGroupName --name $FunctionAppName --connection-string-type $($FunctionAppConnectionString.type) --settings $connectionStringKeyValuePair --slot $availableSlot.name
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet