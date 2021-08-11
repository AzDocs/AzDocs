[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Alias("VnetName")]
    [Parameter(Mandatory)][string] $ApplicationGatewayVnetName,
    [Alias("VnetResourceGroupName")]
    [Parameter(Mandatory)][string] $ApplicationGatewayVnetResourceGroupName,
    [Alias("GatewaySubnetName")]
    [Parameter(Mandatory)][string] $ApplicationGatewaySubnetName,
    [Parameter(Mandatory)][string] $ApplicationGatewayCapacity,
    [Parameter(Mandatory)][string] $ApplicationGatewaySku,
    [Parameter(Mandatory)][string] $CertificateKeyvaultName,
    [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
    [Parameter()][bool] $EnableWafPreventionMode = $false,
    [Parameter()][string] $WafRuleSetType = "OWASP",
    [Parameter()][string] $WafRuleSetVersion = "3.0",
    [Parameter()][System.Object[]] $ResourceTags,

    # Diagnostic Settings
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$gatewaySubnetId = (Invoke-Executable az network vnet subnet show --name $ApplicationGatewaySubnetName --vnet-name $ApplicationGatewayVnetName --resource-group $ApplicationGatewayVnetResourceGroupName | ConvertFrom-Json).id
Write-Host "Gateway Subnet ID: $gatewaySubnetId"

Invoke-Executable az network public-ip create --resource-group $ApplicationGatewayResourceGroupName --name "$($ApplicationGatewayName)-publicip" --allocation-method Static --sku Standard

$publicIpId = (Invoke-Executable az network public-ip show --resource-group $ApplicationGatewayResourceGroupName --name "$($ApplicationGatewayName)-publicip" | ConvertFrom-Json).id

Write-Host "PublicIp: $publicIpId"

$applicationGatewayId = (Invoke-Executable az network application-gateway create --name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --subnet $gatewaySubnetId --capacity $ApplicationGatewayCapacity --sku $ApplicationGatewaySku --http-settings-cookie-based-affinity Enabled --frontend-port 80 --http-settings-port 80 --http-settings-protocol Http --public-ip-address $publicIpId | ConvertFrom-Json).id

# Update Tags
if ($ResourceTags)
{
    Set-ResourceTagsForResource -ResourceId $applicationGatewayId -ResourceTags ${ResourceTags}
}

if ($ApplicationGatewaySku -contains "WAF")
{
    $wafMode = "Detection"
    if ($EnableWafPreventionMode)
    {
        $wafMode = "Prevention"
    }

    Invoke-Executable az network application-gateway waf-config set --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --enabled true --firewall-mode $wafMode --rule-set-type $WafRuleSetType --rule-set-version $WafRuleSetVersion
}

Invoke-Executable az identity create --name "useridentity-$ApplicationGatewayName" --resource-group $ApplicationGatewayResourceGroupName

$identityId = (Invoke-Executable az identity show --name "useridentity-$ApplicationGatewayName" --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id

Write-Host "AppGw Identity: $identityId"

Invoke-Executable az network application-gateway identity assign --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --identity $identityId

Set-SubnetServiceEndpoint -SubnetResourceId $gatewaySubnetId -ServiceEndpointServiceIdentifier 'Microsoft.KeyVault'

# Whitelist our Gateway's subnet in the Certificate Keyvault so we can connect
Invoke-Executable az keyvault network-rule add --resource-group $CertificateKeyvaultResourceGroupName --name $CertificateKeyvaultName --subnet $gatewaySubnetId

# Add diagnostic settings to Application Gateway
Set-DiagnosticSettings -ResourceId $applicationGatewayId -ResourceName $ApplicationGatewayName -LogAnalyticsWorkspaceResourceId $LogAnalyticsWorkspaceResourceId -Logs "[{ 'category': 'ApplicationGatewayAccessLog', 'enabled': true }, { 'category': 'ApplicationGatewayPerformanceLog', 'enabled': true }, { 'category': 'ApplicationGatewayFirewallLog', 'enabled': true }]".Replace("'", '\"') -Metrics "[ { 'category': 'AllMetrics', 'enabled': true } ]".Replace("'", '\"')

Write-Footer -ScopedPSCmdlet $PSCmdlet