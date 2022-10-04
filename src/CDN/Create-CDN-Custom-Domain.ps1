[CmdletBinding(DefaultParameterSetName = 'default')]
param (
  [Parameter(
        ParameterSetName = 'AddHttps',
        HelpMessage = 'Enable https for custom domain',
        Position = 0)]
    [switch]$AddHttps,

    [Parameter(Mandatory)][string] $CdnEndpointName,
    [Parameter(Mandatory)][string] $CdnProfileName,
    [Parameter(Mandatory)][string] $CdnResourceGroupName,
    [Parameter(Mandatory)][string] $Hostname,
    [Parameter(Mandatory)][string] $CdnCustomDomainName,
    [Parameter(Mandatory, ParameterSetName = 'AddHttps')][string] $UserCertSecretName,
    [Parameter(Mandatory, ParameterSetName = 'AddHttps')][string] $UserCertVaultName,
    [Parameter(Mandatory, ParameterSetName = 'AddHttps')][string] $UserCertProtocolType
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

function IsStillEnablingHttps
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CdnProfileName,
        [Parameter(Mandatory)][string] $CdnResourceGroupName,
        [Parameter(Mandatory)][string] $CdnEndpointName,
        [Parameter(Mandatory)][string] $CdnCustomDomainName,
        [Parameter()][int] $RetryCounter = 3
    )

    $count = 0;
    while (((Invoke-Executable az cdn custom-domain show -g $CdnResourceGroupName --profile-name $CdnProfileName --endpoint-name $CdnEndpointName --name $CdnCustomDomainName ) | ConvertFrom-Json).customHttpsProvisioningState -eq 'Enabling' )
    {
        Write-Host 'Enabling Https is still in progress'
        Start-Sleep -Seconds 60
        $count++
        if($count -gt $RetryCounter)
        {
            return $true
        }
    }
    return $false
}

Invoke-Executable az cdn custom-domain create --endpoint-name $CdnEndpointName --hostname $Hostname --resource-group $CdnResourceGroupName --name $CdnCustomDomainName --profile-name $CdnProfileName

if($AddHttps)
{
    $isStillEnablingHttps = IsStillEnablingHttps -CdnProfileName $CdnProfileName -CdnResourceGroupName $CdnResourceGroupName -CdnEndpointName $CdnEndpointName -CdnCustomDomainName $CdnCustomDomainName
    if($isStillEnablingHttps)
    {
        Write-Warning "Still enabling custom https, can take up to 6 hours. Try again later."
    } 
    else
    {
        $certificate = (az keyvault certificate show --name $UserCertSecretName --vault-name $UserCertVaultName | ConvertFrom-Json).id
        # get the version out of the entire id. for example certificate = https://shared-keyvault-dev.vault.azure.net/certificates/dev/38383838383828282828282
        $version = $certificate.split('/')[5]
        Invoke-Executable az cdn custom-domain enable-https --resource-group $CdnResourceGroupName --endpoint-name $CdnEndpointName --name $CdnCustomDomainName --profile-name $CdnEndpointName --user-cert-secret-name $UserCertSecretName --user-cert-vault-name $UserCertVaultName --user-cert-group-name $CdnResourceGroupName --user-cert-protocol-type $UserCertProtocolType --user-cert-secret-version $version 
    } 
}

Write-Footer -ScopedPSCmdlet $PSCmdlet
