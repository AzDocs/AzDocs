<#
.SYNOPSIS
    Ensure the given servicename is set to the given subnet resource identifier
.DESCRIPTION
    Ensure the given servicename is set to the given subnet resource identifier
#>
function Set-SubnetServiceEndpoint {
    [CmdletBinding()]
    param (
        # Resource id of an subnet
        [Parameter(Mandatory)]
        [string]
        $SubnetResourceId,

        # Service to add to the service endpoints
        [Parameter(Mandatory)]
        [string]
        [ValidateSet("Microsoft.Storage", "Microsoft.Sql", "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.Web", "Microsoft.KeyVault", "Microsoft.EventHub", "Microsoft.ServiceBus", "Microsoft.ContainerRegistry", "Microsoft.CognitiveServices")]
        $ServiceName
    )

    #region ===BEGIN IMPORTS===
    . "$PSScriptRoot\Write-HeaderFooter.ps1"
    . "$PSScriptRoot\Invoke-Executable.ps1"
    #endregion ===END IMPORTS===

    Write-Header

    $subnetInformation = Invoke-Executable az network vnet subnet show --ids $SubnetResourceId | ConvertFrom-Json
    [string[]]$endpoints = $subnetInformation.ServiceEndpoints.service
    if (!$endpoints) {
        $endpoints = @()
    }
    if (!($endpoints -contains $ServiceName)) {
        Write-Host "$ServiceName Service Endpoint isnt defined yet. Adding it to the list."
        $endpoints += $ServiceName
        Invoke-Executable az network vnet subnet update --ids $SubnetResourceId --service-endpoints @endpoints
    }
    else {
        Write-Host "$ServiceName Service Endpoint is already defined. No action needed."
    }

    Write-Footer
}