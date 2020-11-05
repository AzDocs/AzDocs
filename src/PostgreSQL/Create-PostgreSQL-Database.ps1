[CmdletBinding()]
param (
    [Parameter()]
    [String] $SqlServerResourceGroupName,
    
    [Parameter()]
    [String] $SqlServerName,

    [Parameter()]
    [String] $SqlDatabaseName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az postgres db create --name $SqlDatabaseName --resource-group $SqlServerResourceGroupName --server $SqlServerName