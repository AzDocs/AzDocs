[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $Namespace
)

az provider register --namespace $Namespace
