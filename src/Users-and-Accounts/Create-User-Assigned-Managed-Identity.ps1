[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $UserAssignedManagedIdentityName,
    [Parameter(Mandatory)][string] $UserAssignedManagedIdentityResourceGroupName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az identity create --name $UserAssignedManagedIdentityName --resource-group $UserAssignedManagedIdentityResourceGroupName

Write-Footer -ScopedPSCmdlet $PSCmdlet