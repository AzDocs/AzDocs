[CmdletBinding()]
param (
    [Alias("DomainName")]
    [Parameter(Mandatory)][string] $IngressDomainName,
    [Alias("GatewayName")]
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Alias("SharedServicesResourceGroupName")]
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ContainerName,
    [Parameter(Mandatory)][string] $ContainerResourceGroupName
)
$ErrorActionPreference = "Continue"

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

try
{
    # Get the IP for the container instance
    $ipAddress = Invoke-Executable -AllowToFail az container show --name $ContainerName --resource-group $ContainerResourceGroupName --query=ipAddress.ip | ConvertFrom-Json

    if(!$ipAddress)
    {
        throw "IP Address for this container could not be found."
    }

    # Get the dashed version of the domainname to use as name for multiple app gateway components
    Write-Host "Fetching dashed domainname"
    $dashedDomainName = Get-DashedDomainname -DomainName $IngressDomainName
    Write-Host "Dashed domainname: $dashedDomainName"

    # Adding container to the list of backends
    Write-Host "Adding backend $ipAddress to the backendpool"
    if(!(az network application-gateway address-pool show --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpspool" --query "backendAddresses[?ipAddress=='$($ipAddress)']" | ConvertFrom-Json).ipAddress)
    {
        Invoke-Executable az network application-gateway address-pool update --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpspool" --resource-group $ApplicationGatewayResourceGroupName --add backendAddresses ip_address=$ipAddress
        Write-Host "Added backend to the backendpool"
    }
    else
    {
        Write-Host "IpAddress $ipAddress already exists in backendpool"
    }
}
catch
{
    throw
}
finally
{
    [Console]::ResetColor()
}

Write-Footer -ScopedPSCmdlet $PSCmdlet