function Get-VnetSubnetIdentifiers
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $VnetName,
        [Parameter(Mandatory)][string] $SubnetName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $vnet = Invoke-Executable az network vnet list | ConvertFrom-Json | Where-Object name -EQ $VnetName
    if (!$vnet)
    {
        throw "Could not find vnet $VnetName"
    }

    $subnet = $vnet.subnets | Where-Object name -EQ $SubnetName
    if (!$subnet)
    {
        Throw "Could not find subnet $SubnetName"
    } 

    $vnetsubnetIdentifiers = [PSCustomObject]@{
        VnetIdentifier   = $vnet.id
        SubnetIdentifier = $subnet.id
    }

    Write-Output $vnetsubnetIdentifiers 
   
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}