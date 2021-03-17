[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $CertificateNameForFunctionApp,
    [Parameter(Mandatory)][string] $CertificateFilePath
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$certificateEncryptedPassword = ConvertTo-SecureString -String "ThisReallyDoesntMatterButWeNeedIt123!" -AsPlainText -Force
$cert = New-AzApplicationGatewaySslCertificate -Name $CertificateNameForFunctionApp -CertificateFile $CertificateFilePath -Password $certificateEncryptedPassword
$apiVersion = '2018-02-01'

if ($cert) {
    $PropertiesObject = @{
        blob                      = $cert.Data;
        publicCertificateLocation = "CurrentUserMy"
    }

    $resource = Get-AzFunctionApp -ResourceGroupName $FunctionAppResourceGroupName -Name $FunctionAppName
    $resourceName = $resource.Name + "/" + $CertificateNameForFunctionApp
    New-AzResource -Location $resource.Location -PropertyObject $PropertiesObject -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force

    #Apply the cert to the deployment slots if any
    $slots = Get-AzResource -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/slots -ResourceName $FunctionAppName -ApiVersion $apiVersion
    foreach ($slot in $slots) {
        $resourceName = $slot.Name + "/" + $CertificateNameForFunctionApp
        New-AzResource -Location $slot.Location -PropertyObject $PropertiesObject -ResourceGroupName $slot.resourceGroupName -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet