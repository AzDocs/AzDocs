[CmdletBinding()]
param (
    [Alias("Namespace")]
    [Parameter(Mandatory)][string] $ResourceProviderNamespace
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az provider register --namespace $ResourceProviderNamespace

Write-Footer -ScopedPSCmdlet $PSCmdlet