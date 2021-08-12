[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName,
    [Alias("CertificateNameForFunctionApp")]
    [Parameter(Mandatory)][string] $FunctionAppCertificateName,
    [Alias("CertificateFilePath")]
    [Parameter(Mandatory)][string] $FunctionAppCertificateFilePath,

    # Deploymentslots
    [Parameter()][string] $FunctionSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$cert = New-AzApplicationGatewaySslCertificate -Name $FunctionAppCertificateName -CertificateFile $FunctionAppCertificateFilePath
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
        $resourceName = $resource.Name + "/" + $FunctionAppCertificateName
        New-AzResource -Location $resource.Location -PropertyObject $propertiesObject -ResourceGroupName $resource.ResourceGroup -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }
    else
    {
        $resource = Get-AzFunctionApp -ResourceGroupName $FunctionAppResourceGroupName -Name $FunctionAppName
        $resourceName = $resource.Name + "/" + $FunctionAppCertificateName
        New-AzResource -Location $resource.Location -PropertyObject $PropertiesObject -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
    }

    #Apply the cert to the deployment slots if desired
    if ($ApplyToAllSlots -eq $True)
    {
        $slots = Get-AzResource -ResourceGroupName $resource.resourceGroupName -ResourceType Microsoft.Web/sites/slots -ResourceName $FunctionAppName -ApiVersion $apiVersion
        foreach ($slot in $slots)
        {
            $resourceName = $slot.Name + "/" + $FunctionAppCertificateName
            New-AzResource -Location $slot.Location -PropertyObject $propertiesObject -ResourceGroupName $slot.resourceGroupName -ResourceType Microsoft.Web/sites/slots/publicCertificates -ResourceName $resourceName -ApiVersion $apiVersion -Force
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet