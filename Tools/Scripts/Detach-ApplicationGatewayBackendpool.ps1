<#
.SYNOPSIS
    Removing a virtual machine from an application gateway backend address pool.
.DESCRIPTION
    Removing a virtual machine from an application gateway backend address pool.
.NOTES
    Support virtual machine with 1 nic and 1 ipconfiguration on the nic.
.EXAMPLE
    ./Azure.PlatformProvisioning\Tools\Scripts\Detach-ApplicationGatewayBackendpool.ps1
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SubscriptionName = 'comp-azurept-dev',

    [Parameter()]
    [string]
    $ResourceGroupVM = 'comp-AppGwTst-dev',

    [Parameter()]
    [string]
    $VirtualMachineName = 'myVM',
    [Parameter()]
    [string]
    $ApplicationGatewayBackendAddressPoolId = '/subscriptions/5490ec8f-64bc-4d3d-81c7-7773551a8b51/resourceGroups/platform-rg/providers/Microsoft.Network/applicationGateways/agw-01-myteam-pub-dev/backendAddressPools/myapp-someorg-com-backendaddresspool'
)

Set-AzContext -Subscription $SubscriptionName

$virtualMachine = Get-AzVM -ResourceGroupName $ResourceGroupVM -Name $VirtualMachineName
if ($virtualMachine.NetworkProfile.NetworkInterfaces.Count -eq 1)
{
    $nicId = $virtualMachine.NetworkProfile.NetworkInterfaces[0].Id
    $nic = Get-AzNetworkInterface -ResourceId $nicId
    if ($nic.IpConfigurations.Count -eq 1)
    {
        $configuration = $nic.IpConfigurations[0]
        $pools = $configuration.ApplicationGatewayBackendAddressPools
        $backendAddressPool = $pools | Where-Object Id -EQ $ApplicationGatewayBackendAddressPoolId
        if ($backendAddressPool)
        {
            Write-Host 'BackendAddressPool found, going to remove it'
            $pools.Remove($backendAddressPool)
            $nic | Set-AzNetworkInterfaceIpConfig -Name $configuration.Name -ApplicationGatewayBackendAddressPool $pools
            $nic | Set-AzNetworkInterface
            Write-Host 'BackendAddressPool removed'
        }
        else
        {
            Write-Host 'Could not find backendAddressPool'
        }
    }
    else
    {
        Write-Warning 'Multiple configurations found for nic'
    }
}
else
{
    Write-Warning 'Multiple Nics found'
}