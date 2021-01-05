[CmdletBinding()]
param (
    [Parameter()]
    [String] $appServiceResourceGroupName,

    [Parameter()]
    [string] $appServiceName,

    [Parameter()]
    [string] $certificateNameForAppService,

    [Parameter()]
    [string] $certificateFilePath
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
#endregion ===END IMPORTS===

Write-Header

$certificateEncryptedPassword = ConvertTo-SecureString -String "ThisReallyDoesntMatterButWeNeedIt123!" -AsPlainText -Force
$cert = New-AzApplicationGatewaySslCertificate -Name $certificateNameForAppService -CertificateFile $certificateFilePath -Password $certificateEncryptedPassword
$apiVersion = '2018-02-01'

if ($cert) {
    $PropertiesObject = @{
        blob                      = $cert.Data;
        publicCertificateLocation = "CurrentUserMy"
    }

    $resource = Get-AzWebApp -ResourceGroupName $appServiceResourceGroupName -Name $appServiceName
    $resourceName = $resource.Name + "/" + $certificateNameForAppService
    New-AzResource -Location $resource.Location -PropertyObject $PropertiesObject -ResourceGroupName $resource.ResourceGroup -ResourceType Microsoft.Web/sites/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force

    #Apply the cert to the deployment slots if any
    $slots = Get-AzResource -ResourceGroupName $resource.ResourceGroup -ResourceType Microsoft.Web/sites/slots -ResourceName $appServiceName -ApiVersion $apiVersion
    foreach ($slot in $slots) {
        $resourceName = $slot.Name + "/" + $certificateNameForAppService
        New-AzResource -Location $slot.Location -PropertyObject $PropertiesObject -ResourceGroupName $slot.ResourceGroupName -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }
}

Write-Footer