<#
.SYNOPSIS
Configure the Application Gateway for a site.

.DESCRIPTION
Configure the Application Gateway for sites for a public or private certificate.

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $domainName,
    [Parameter(Mandatory)][string] $gatewayName,
    [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
    [Parameter(Mandatory)][string] $containerName,
    [Parameter(Mandatory)][string] $containerResourceGroupName
)
$ErrorActionPreference = "Continue"

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
. "$PSScriptRoot\..\common\AppGateway-Helper-Functions.ps1"
#endregion ===END IMPORTS===

Write-Header

try
{
    #TODO does invoke-executable have an extra switch for something like this?
    # Get the IP for the container instance
    $ipAddress = Invoke-Executable az container show --name $containerName --resource-group $containerResourceGroupName --query=ipAddress.ip | ConvertFrom-Json

    if(!$ipAddress)
    {
        throw "IP Address for this container could not be found."
    }

    # Get the dashed version of the domainname to use as name for multiple app gateway components
    Write-Host "Fetching dashed domainname"
    $dashedDomainName = Get-DashedDomainname -domainName $domainName
    Write-Host "Dashed domainname: $dashedDomainName"

    # Adding container to the list of backends
    Write-Host "Adding backend to the backendpool"
    Invoke-Executable az network application-gateway address-pool update --gateway-name $gatewayName --name "$dashedDomainName-httpspool" --resource-group $sharedServicesResourceGroupName --add backendAddresses '{ "ip_address": "{' + $ipAddress + '}" }'
    Write-Host "Added backend to the backendpool"
}
catch
{
    throw
}
finally
{
    [Console]::ResetColor()
}

Write-Footer