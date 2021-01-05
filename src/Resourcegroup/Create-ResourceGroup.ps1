[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $location,

    [Parameter(Mandatory)]
    [String] $resourceGroupName,

    [Parameter()]
    [string[]] $resourceTags
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===
Write-Header

Invoke-Executable az group create --location $location --name $resourceGroupName --tags @resourceTags

Write-Footer