[CmdletBinding()]
param (
    [Alias("Location")]
    [Parameter(Mandatory)][string] $ResourceGroupLocation,
    [Parameter(Mandatory)][string] $ResourceGroupName,
    [Parameter(Mandatory)][string[]] $ResourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===
Write-Header

Invoke-Executable az group create --location $ResourceGroupLocation --name $ResourceGroupName --tags @ResourceTags

Write-Footer