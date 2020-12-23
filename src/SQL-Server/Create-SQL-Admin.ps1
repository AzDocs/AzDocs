[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $UserName,

    [Parameter(Mandatory)]
    [String] $Password
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===
Write-Header

invoke-Executable az ad user create --display-name "SQL Admin $($UserName)" --password $Password --user-principal-name $UserName --force-change-password-next-login false

Write-Footer