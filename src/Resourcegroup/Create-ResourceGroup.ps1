[CmdletBinding()]
param (
    [Alias("Location")]
    [Parameter(Mandatory)][string] $ResourceGroupLocation,
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Parameter(Mandatory)][string[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az group create --location $ResourceGroupLocation --name $ResourceGroupName --tags @ResourceTags

Write-Footer -ScopedPSCmdlet $PSCmdlet