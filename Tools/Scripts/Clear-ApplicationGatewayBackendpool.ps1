<#
.SYNOPSIS
    removing a virtual machine to an application gateway backend address pool.
.DESCRIPTION
    removing a virtual machine to an application gateway backend address pool.
.NOTES
    Support virtual machine with 1 nic, 1 ipconfiguration on the nic
.EXAMPLE
    Azure.PlatformProvisioning\Tools\Scripts\Clear-ApplicationGatewayBackendpool.ps1
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
    $VirtualMachineName = 'myVM'
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
        if ($pools.Count -gt 0 )
        {
            Write-Host 'Removing all backendAddressPools'
            $pools.RemoveAll()
            $nic | Set-AzNetworkInterfaceIpConfig -Name $configuration.Name -ApplicationGatewayBackendAddressPool $pools 
            $nic | Set-AzNetworkInterface
            Write-Host 'BackendAddressPools removed'
        }
        else
        {
            Write-Host 'Could not find backendAddressPools'
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