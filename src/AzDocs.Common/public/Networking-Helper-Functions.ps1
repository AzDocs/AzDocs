function Get-StartIpInIpv4Network
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $SubnetCidr
    )

    $networkAddress = ($SubnetCidr.split("/"))[0]
    $networkIp = ([System.Net.IPAddress]$networkAddress).GetAddressBytes()
    [Array]::Reverse($networkIp)
    $networkIp = ([System.Net.IPAddress]($networkIp -join ".")).Address
    $startIP = $networkIp +1

    if (($startIP.Gettype()).Name -ine "double")
    {
        $startIP = [Convert]::ToDouble($startIP)
    }
    $startIP = [System.Net.IPAddress]$startIP
    return $startIP.IPAddressToString
}

function Get-EndIpInIpv4Network
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $SubnetCidr
    )

    $networkAddress = ($SubnetCidr.split("/"))[0]
    $networkLength = ($SubnetCidr.split("/"))[1]
    $IpLength = 32-$networkLength
    $numberOfIps = ([System.Math]::Pow(2, $IpLength)) -2
    $networkIp = ([System.Net.IPAddress]$networkAddress).GetAddressBytes()
    [Array]::Reverse($networkIp)
    $networkIp = ([System.Net.IPAddress]($networkIp -join ".")).Address
    $endIp = $networkIp + $numberOfIps
    
    if (($endIp.Gettype()).Name -ine "double")
    {
        $endIp = [Convert]::ToDouble($endIp)
    }
    $endIp = [System.Net.IPAddress]$endIp

    return $endIp.IPAddressToString
}