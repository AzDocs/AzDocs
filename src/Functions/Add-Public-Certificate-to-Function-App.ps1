[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Parameter(Mandatory)][string] $CertificateNameForFunctionApp,
    [Parameter(Mandatory)][string] $CertificateFilePath,

    # Deploymentslots
    [Parameter()][string] $FunctionSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$cert = New-AzApplicationGatewaySslCertificate -Name $CertificateNameForFunctionApp -CertificateFile $CertificateFilePath
$apiVersion = '2018-02-01'

if ($cert)
{
    $propertiesObject = @{
        blob                      = $cert.Data;
        publicCertificateLocation = "CurrentUserMy"
    }

    if ($FunctionSlotName)
    {
        $resource = Get-AzWebAppSlot -ResourceGroupName $FunctionAppResourceGroupName -Name $FunctionAppName -Slot $FunctionSlotName
        $resourceName = $resource.Name + "/" + $CertificateNameForFunctionApp
        New-AzResource -Location $resource.Location -PropertyObject $propertiesObject -ResourceGroupName $resource.ResourceGroup -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }
    else
    {
        $resource = Get-AzFunctionApp -ResourceGroupName $FunctionAppResourceGroupName -Name $FunctionAppName
        $resourceName = $resource.Name + "/" + $CertificateNameForFunctionApp
        New-AzResource -Location $resource.Location -PropertyObject $PropertiesObject -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }

    #Apply the cert to the deployment slots if desired
    if ($ApplyToAllSlots -eq $True)
    {
        $slots = Get-AzResource -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/slots -ResourceName $FunctionAppName -ApiVersion $apiVersion
        foreach ($slot in $slots)
        {
            $resourceName = $slot.Name + "/" + $CertificateNameForFunctionApp
            New-AzResource -Location $slot.Location -PropertyObject $propertiesObject -ResourceGroupName $slot.resourceGroupName -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet