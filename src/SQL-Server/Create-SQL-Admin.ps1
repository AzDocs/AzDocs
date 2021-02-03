[CmdletBinding()]
param (
    [Alias("UserName")]
    [Parameter(Mandatory)][string] $AdUserName,
    [Alias("Password")]
    [Parameter(Mandatory)][string] $AdPassword
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===
Write-Header

Invoke-Executable az ad user create --display-name "SQL Admin $($AdUserName)" --password $AdPassword --user-principal-name $AdUserName --force-change-password-next-login false

Write-Footer