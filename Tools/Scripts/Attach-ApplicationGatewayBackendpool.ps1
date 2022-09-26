<#
.SYNOPSIS
    Adding a virtual machine to an application gateway backend address pool.
.DESCRIPTION
    Adding a virtual machine to an application gateway backend address pool.
.NOTES
    Support virtual machine with 1 nic, 1 ipconfiguration on the nic
.EXAMPLE
    Azure.PlatformProvisioning\Tools\Scripts\Attach-ApplicationGatewayBackendpool.ps1
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
        if ($pools.Id -notcontains $ApplicationGatewayBackendAddressPoolId)
        {
            Write-Host 'Going to join the NIC to the Appication Gateway Backend Address Pool'
            $backendPool = [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayBackendAddressPool]::new()
            $backendPool.Id = $ApplicationGatewayBackendAddressPoolId
            $pools.Add( $backendPool)
            $nic | Set-AzNetworkInterfaceIpConfig -Name $configuration.Name -ApplicationGatewayBackendAddressPool $pools 
            $nic | Set-AzNetworkInterface
            Write-Host 'NIC joined the Appication Gateway Backend Address Pool'
        }
        else
        {
            Write-Host 'Nic Already has the backendpool'
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