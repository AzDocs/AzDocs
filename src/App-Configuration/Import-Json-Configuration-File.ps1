[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $Label,
    [Parameter(Mandatory)][string] $JsonFilePath,
    [Parameter()][string] $KeyValuePairSeparator = ":",
    [Parameter(Mandatory)][string] $KeyPrefix
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az appconfig kv import --name $AppConfigName --label $Label --source file --path $JsonFilePath --format json --separator $KeyValuePairSeparator --prefix $KeyPrefix --yes

Write-Footer -ScopedPSCmdlet $PSCmdlet