[CmdletBinding()]
param (
    [Parameter()]
    [String] $functionAppResourceGroupName,

    [Parameter()]
    [string] $functionAppName,

    [Parameter()]
    [string] $certificateNameForFunctionApp,

    [Parameter()]
    [string] $certificateFilePath
)

$certificateEncryptedPassword = ConvertTo-SecureString -String "ThisReallyDoesntMatterButWeNeedIt123!" -AsPlainText -Force
$cert = New-AzApplicationGatewaySslCertificate -Name $certificateNameForFunctionApp -CertificateFile $certificateFilePath -Password $certificateEncryptedPassword
$apiVersion = '2018-02-01'

if ($cert) {
    $PropertiesObject = @{
        blob                      = $cert.Data;
        publicCertificateLocation = "CurrentUserMy"
    }

    $resource = Get-AzFunctionApp -ResourceGroupName $functionAppResourceGroupName -Name $functionAppName
    $resourceName = $resource.Name + "/" + $certificateNameForFunctionApp
    New-AzResource -Location $resource.Location -PropertyObject $PropertiesObject -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force

    #Apply the cert to the deployment slots if any
    $slots = Get-AzResource -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/slots -ResourceName $functionAppName -ApiVersion $apiVersion
    foreach ($slot in $slots) {
        $resourceName = $slot.Name + "/" + $certificateNameForFunctionApp
        New-AzResource -Location $slot.Location -PropertyObject $PropertiesObject -ResourceGroupName $slot.resourceGroupName -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }
}