[CmdletBinding()]
param (
    [Alias("SharedServicesKeyvaultName")]
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultCertificateName,
    [Parameter(Mandatory)][string] $PfxFilename,
    [Parameter(Mandatory)][string] $PfxPassword
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Invoke-Executable az keyvault certificate import --file $PfxFilename --name $KeyvaultCertificateName --vault-name $KeyvaultName --password $PfxPassword

Write-Footer