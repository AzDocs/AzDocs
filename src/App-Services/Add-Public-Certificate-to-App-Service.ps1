[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Alias("CertificateNameForAppService")]
    [Parameter(Mandatory)][string] $AppServiceCertificateName,
    [Alias("CertificateFilePath")]
    [Parameter(Mandatory)][string] $AppServiceCertificateFilePath
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$certificateEncryptedPassword = ConvertTo-SecureString -String "ThisReallyDoesntMatterButWeNeedIt123!" -AsPlainText -Force
$cert = New-AzApplicationGatewaySslCertificate -Name $AppServiceCertificateName -CertificateFile $AppServiceCertificateFilePath -Password $certificateEncryptedPassword
$apiVersion = '2018-02-01'

if ($cert) {
    $PropertiesObject = @{
        blob                      = $cert.Data;
        publicCertificateLocation = "CurrentUserMy"
    }

    $resource = Get-AzWebApp -ResourceGroupName $AppServiceResourceGroupName -Name $AppServiceName
    $resourceName = $resource.Name + "/" + $AppServiceCertificateName
    New-AzResource -Location $resource.Location -PropertyObject $PropertiesObject -ResourceGroupName $resource.ResourceGroup -ResourceType Microsoft.Web/sites/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force

    #Apply the cert to the deployment slots if any
    $slots = Get-AzResource -ResourceGroupName $resource.ResourceGroup -ResourceType Microsoft.Web/sites/slots -ResourceName $AppServiceName -ApiVersion $apiVersion
    foreach ($slot in $slots) {
        $resourceName = $slot.Name + "/" + $AppServiceCertificateName
        New-AzResource -Location $slot.Location -PropertyObject $PropertiesObject -ResourceGroupName $slot.ResourceGroupName -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet