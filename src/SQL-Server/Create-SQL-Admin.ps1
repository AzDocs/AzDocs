[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $UserName,

    [Parameter(Mandatory)]
    [String] $Password
)

az ad user create --display-name "SQL Admin $($UserName)" --password $Password --user-principal-name $UserName --force-change-password-next-login false