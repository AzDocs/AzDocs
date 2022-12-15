[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
    [Parameter(Mandatory)][string][ValidateSet('CustomerCertificate', 'ManagedCertificate')] $CustomDomainCertificateType,
    [Parameter(Mandatory)][string] $CustomDomainNameName, 
    [Parameter(Mandatory)][string] $HostName, 
    [Parameter()][string][ValidateSet('TLS1_0', 'TLS1_2')] $CustomDomainMinimalTLSVersion = 'TLS1_2', 

    # Certificate
    [Parameter(Mandatory)][string] $CertificatePath,
    [Parameter(Mandatory)][string] $CertificatePassword,
    [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
    [Parameter(Mandatory)][string] $CertificateKeyvaultName,

    # Service Princial Object Id
    [Parameter(Mandatory)][string] $ServicePrincipalObjectId
)


#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Check TLS version
Assert-TLSVersion -TlsVersion $CustomDomainMinimalTLSVersion

# Get certificatename 
$value = Get-CommonNameAndCertificateName -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword
if ($null -eq $value.CommonName -or $null -eq $value.CertificateName) {
    throw "Something went wrong with generating the certificate name."
}

# Add certificate to FrontDoor
$paramForSecret = @{
    CertificatePath                      = $CertificatePath;
    CertificatePassword                  = $CertificatePassword;
    CertificateKeyvaultResourceGroupName = $CertificateKeyvaultResourceGroupName;
    CertificateKeyvaultName              = $CertificateKeyvaultName;
    FrontDoorProfileName                 = $FrontDoorProfileName;
    FrontDoorResourceGroup               = $FrontDoorResourceGroup;
    IngressDomainName                    = $HostName;
    CommonName                           = $value.CommonName;
    CertificateName                      = $value.CertificateName;
    ServicePrincipalObjectId             = $ServicePrincipalObjectId;
}

Add-SecretToFrontDoor @paramForSecret

# Create custom domain
Invoke-Executable az afd custom-domain create --certificate-type $CustomDomainCertificateType --custom-domain-name $CustomDomainNameName --host-name $HostName --minimum-tls-version $CustomDomainMinimalTLSVersion.Replace('_', '') --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --secret $value.CertificateName

# Return DNS TXT record information
$validationProperties = (Invoke-Executable -AllowToFail az afd custom-domain show --custom-domain-name $CustomDomainNameName --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup | ConvertFrom-Json).validationProperties
if ($validationProperties) {
    Write-Host "For traffic to be able to get delivered, please create a DNS TXT record with as record '_dnsauth.{your custom domain}' with the following validationToken: $($validationProperties.validationToken)"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet