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
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az group create --location $location --name $resourceGroupName --tags @resourceTags