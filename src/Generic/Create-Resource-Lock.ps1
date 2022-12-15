[CmdletBinding()]
param (
    [Parameter(Mandatory)][String] $ResourceGroupName,
    [Parameter()][String] $ResourceName,
    [Parameter()][Switch] $IncludeResourceGroupLock,
    [Parameter()][Switch] $IncludeResourceLock,
    [Parameter()][ValidateSet('CanNotDelete', 'ReadOnly')][string] $LockType = 'CanNotDelete'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($IncludeResourceGroupLock)
{
    Invoke-Executable az group lock create --lock-type $LockType --name $LockType --resource-group $ResourceGroupName
}

if ($IncludeResourceLock)
{
    if (!$ResourceName)
    {
        throw 'If you want to place a resourcelock, please pass the ResourceName.'
    }

    $resources = (((Invoke-Executable az resource list --resource-group $ResourceGroupName) | ConvertFrom-Json) | Where-Object { $_.name -eq $ResourceName }) | Select-Object

    foreach ($resource in $resources)
    {
        Invoke-Executable az resource lock create --lock-type $LockType -n $LockType --resource $resource.id
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet