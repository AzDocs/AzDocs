[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $IngressDomainName,
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
    [Parameter(Mandatory)][string] $CertificateKeyvaultName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Remove-ApplicationGatewayEntrypoint -IngressDomainName $IngressDomainName -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -CertificateKeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName -CertificateKeyvaultName $CertificateKeyvaultName

Write-Footer -ScopedPSCmdlet $PSCmdlet