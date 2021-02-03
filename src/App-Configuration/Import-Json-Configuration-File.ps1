[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $Label,
    [Parameter(Mandatory)][string] $JsonFilePath,
    [Parameter()][string] $KeyValuePairSeparator = ":",
    [Parameter(Mandatory)][string] $KeyPrefix
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az appconfig kv import --name $AppConfigName --label $Label --source file --path $JsonFilePath --format json --separator $KeyValuePairSeparator --prefix $KeyPrefix --yes

Write-Footer