[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $IngressDomainName,
    [Parameter(Mandatory)][string] $SSLProfileName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch Application Gateway ID
Write-Host 'Fetching Application Gateway ID'
$applicationGateway = Invoke-Executable az network application-gateway show --name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json
Write-Host "Fetched Application Gateway ID: $($applicationGateway.id)"

# Get the dashed version of the domainname to use as name for multiple app gateway components
Write-Host 'Fetching dashed domainname'
$dashedDomainName = Get-DashedDomainname -DomainName $IngressDomainName
Write-Host "Dashed domainname: $dashedDomainName"

# Create Listener
Write-Host 'Fetching HTTPS Listener'
$httpListenerId = (Invoke-Executable az network application-gateway http-listener show --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpslistener" | ConvertFrom-Json).id

if (!$httpListenerId)
{
    throw
    "No such listenerId found named '$dashedDomainName-httpslistener' found on gateway '$ApplicationGatewayName'"
}

Write-Host "Fetched HTTPS Listener: $httpListenerId"

# Create Listener
Write-Host 'Fetching SSL Profile ID'
$sslProfileId = (Invoke-Executable az network application-gateway ssl-profile list --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName | ConvertFrom-Json | Where-Object name -EQ $SSLProfileName).id

if (!$sslProfileId)
{
    throw
    "No such profile named '$SSLProfileName' found on gateway '$ApplicationGatewayName'"
}
Write-Host "Fetched SSL Profile ID: $sslProfileId"
if ($httpListenerId -match '\/subscriptions\/(?<SubscriptionId>.*)\/resourceGroups\/(?<ResourceGroupName>.*)\/providers\/Microsoft.Network\/applicationGateways\/(?<ApplicationGatewayName>.*)\/httpListeners\/(?<httpListenerName>.*)')
{
    Invoke-Executable az network application-gateway http-listener update --gateway-name $Matches.ApplicationGatewayName --name $Matches.httpListenerName --resource-group $Matches.ResourceGroupName --set sslProfile.Id=$sslProfileId
}
else
{
    throw "Could match Listener resource id '$httpListenerId'"
}


Write-Footer -ScopedPSCmdlet $PSCmdlet