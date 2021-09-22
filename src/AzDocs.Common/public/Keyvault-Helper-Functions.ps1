function Set-KeyvaultPermissions
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $KeyvaultName,
        [Parameter(Mandatory)][string] $ManagedIdentityId, 
        [Parameter()][string] $KeyvaultCertificatePermissions,
        [Parameter()][string] $KeyvaultKeyPermissions,
        [Parameter()][string] $KeyvaultSecretPermissions,
        [Parameter()][string] $KeyvaultStoragePermissions
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $kvcp = $KeyvaultCertificatePermissions -split ' '
    $kvkp = $KeyvaultKeyPermissions -split ' '
    $kvsp = $KeyvaultSecretPermissions -split ' '
    $kvstp = $KeyvaultStoragePermissions -split ' '

    Invoke-Executable az keyvault set-policy --certificate-permissions @kvcp --key-permissions @kvkp --secret-permissions @kvsp --storage-permissions @kvstp --object-id $ManagedIdentityId --name $KeyvaultName

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}
