[CmdletBinding()]
param (
    [Parameter()]
    [String] $pfxFilename,

    [Parameter()]
    [String] $keyvaultCertificateName,

    [Parameter()]
    [String] $sharedServicesKeyvaultName,

    [Parameter()]
    [String] $pfxPassword
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az keyvault certificate import --file $pfxFilename --name $keyvaultCertificateName --vault-name $sharedServicesKeyvaultName --password $pfxPassword

Write-Footer