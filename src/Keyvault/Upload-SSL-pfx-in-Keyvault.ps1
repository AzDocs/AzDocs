[CmdletBinding()]
param (
    [Alias('SharedServicesKeyvaultName')]
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $KeyvaultCertificateName,
    [Parameter(Mandatory)][string] $PfxFilename,
    [Parameter(Mandatory)][string] $PfxPassword
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az keyvault certificate import --file $PfxFilename --name $KeyvaultCertificateName --vault-name $KeyvaultName --password $PfxPassword

Write-Footer -ScopedPSCmdlet $PSCmdlet