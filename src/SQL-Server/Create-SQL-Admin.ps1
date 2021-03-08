[CmdletBinding()]
param (
    [Alias("UserName")]
    [Parameter(Mandatory)][string] $AdUserName,
    [Alias("Password")]
    [Parameter(Mandatory)][string] $AdPassword
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az ad user create --display-name "SQL Admin $($AdUserName)" --password $AdPassword --user-principal-name $AdUserName --force-change-password-next-login false

Write-Footer -ScopedPSCmdlet $PSCmdlet