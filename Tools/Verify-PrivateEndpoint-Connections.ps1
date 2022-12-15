[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SubscriptionName,
    [Parameter()][bool] $EnableDeletion = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$((Get-Item $PSScriptRoot).Parent)\src\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$privateEndpoints = Invoke-Executable az network private-endpoint list --subscription $SubscriptionName | ConvertFrom-Json
$disconnectedPrivateEndpoints = $privateEndpoints | Where-Object { $_.privateLinkServiceConnections.privateLinkServiceConnectionState.status -eq 'Disconnected' }

foreach ($disconnectedPrivateEndpoint in $disconnectedPrivateEndpoints)
{
    Write-Host "$($disconnectedPrivateEndpoint.name) has the status of Disconnected. Please check this private endpoint."

    if ($EnableDeletion)
    {
        Write-Host "Deleting private endpoint $($disconnectedPrivateEndpoint.name)"
        Invoke-Executable az network private-endpoint delete --name $disconnectedPrivateEndpoint.name --resource-group $disconnectedPrivateEndpoint.resourceGroup
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet