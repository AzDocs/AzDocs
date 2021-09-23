function Get-StartIpInIpv4Network
{
	[OutputType([string])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)][string] $SubnetCidr
	)

	if ($SubnetCidr -eq '0.0.0.0/0')
	{
		return "0.0.0.0"
	}

	$splittedIpAddress = $SubnetCidr -split '/'
	$subnetMask = ConvertTo-IPv4MaskString -MaskBits $splittedIpAddress[1]

	$BinarySubnetMask = ""
	if ($splittedIpAddress[1] -ne "32")
	{
		$BinarySubnetMask = (Convert-SubnetMaskToBinary $subnetMask).replace(".", "")
	}
	$BinaryNetworkAddressSection = $BinarySubnetMask.replace("1", "")
	$BinaryNetworkAddressLength = $BinaryNetworkAddressSection.length
	$CIDR = 32 - $BinaryNetworkAddressLength
	$BinaryIP = (Convert-IPToBinary $splittedIpAddress[0]).Replace(".", "")
	$BinaryIPNetworkSection = $BinaryIP.substring(0, $CIDR)
    
	#Starting IP
	$FirstAddress = $BinaryNetworkAddressSection -replace "0$", "1"
	$BinaryFirstAddress = $BinaryIPNetworkSection + $FirstAddress
	$strFirstIP = Convert-BinaryIPAddress $BinaryFirstAddress
	return $strFirstIP
}

function Get-EndIpInIpv4Network
{
	[OutputType([string])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)][string] $SubnetCidr
	)

	if ($SubnetCidr -eq '0.0.0.0/0')
	{
		return "255.255.255.255"
	}

	$splittedIpAddress = $SubnetCidr -split '/'
	$subnetMask = ConvertTo-IPv4MaskString -MaskBits $splittedIpAddress[1]

	$BinarySubnetMask = ""
	if ($splittedIpAddress[1] -ne "32")
	{
		$BinarySubnetMask = (Convert-SubnetMaskToBinary $subnetMask).replace(".", "")
	}
	$BinaryNetworkAddressSection = $BinarySubnetMask.replace("1", "")
	$BinaryNetworkAddressLength = $BinaryNetworkAddressSection.length
	$CIDR = 32 - $BinaryNetworkAddressLength
	$BinaryIP = (Convert-IPToBinary $splittedIpAddress[0]).Replace(".", "")
	$BinaryIPNetworkSection = $BinaryIP.substring(0, $CIDR)
       
	#End IP
	$LastAddress = ($BinaryNetworkAddressSection -replace "0", "1") -replace "1$", "0"
	$BinaryLastAddress = $BinaryIPNetworkSection + $LastAddress
	$strLastIP = Convert-BinaryIPAddress $BinaryLastAddress
	return $strLastIP
}



function ConvertTo-IPv4MaskString
{
	param(
		[Parameter(Mandatory = $true)]
		[ValidateRange(0, 32)]
		[Int] $MaskBits
	)
	$mask = ([Math]::Pow(2, $MaskBits) - 1) * [Math]::Pow(2, (32 - $MaskBits))
	$bytes = [BitConverter]::GetBytes([UInt32] $mask)
	(($bytes.Count - 1)..0 | ForEach-Object { [String] $bytes[$_] }) -join "."
}


function Test-IP ($strIP)
{
	$bValidIP = $true
	$arrSections = @()
	$arrSections += $strIP.split(".")
	#firstly, make sure there are 4 sections in the IP address
	if ($arrSections.count -ne 4) { $bValidIP = $false }
	
	#secondly, make sure it only contains numbers and it's between 0-254
	if ($bValidIP)
	{
		[reflection.assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
		foreach ($item in $arrSections)
		{
			if (!([Microsoft.VisualBasic.Information]::isnumeric($item))) { $bValidIP = $false }
		}
	}
	
	if ($bValidIP)
	{
		foreach ($item in $arrSections)
		{
			$item = [int]$item
			if ($item -lt 0 -or $item -gt 254) { $bValidIP = $false }
		}
	}
	
	Return $bValidIP
}

function Test-SubnetMask ($strSubnetMask)
{
	$bValidMask = $true
	$arrSections = @()
	$arrSections += $strSubnetMask.split(".")
	#firstly, make sure there are 4 sections in the subnet mask
	if ($arrSections.count -ne 4) { $bValidMask = $false }
	
	#secondly, make sure it only contains numbers and it's between 0-255
	if ($bValidMask)
	{
		[reflection.assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
		foreach ($item in $arrSections)
		{
			if (!([Microsoft.VisualBasic.Information]::isnumeric($item))) { $bValidMask = $false }
		}
	}
	
	if ($bValidMask)
	{
		foreach ($item in $arrSections)
		{
			$item = [int]$item
			if ($item -lt 0 -or $item -gt 255) { $bValidMask = $false }
		}
	}
	
	#lastly, make sure it is actually a subnet mask when converted into binary format
	if ($bValidMask)
	{
		foreach ($item in $arrSections)
		{
			$binary = [Convert]::ToString($item, 2)
			if ($binary.length -lt 8)
			{
				do
    {
					$binary = "0$binary"
				} while ($binary.length -lt 8)
			}
			$strFullBinary = $strFullBinary + $binary
		}
		if ($strFullBinary.contains("01")) { $bValidMask = $false }
		if ($bValidMask)
		{
			$strFullBinary = $strFullBinary.replace("10", "1.0")
			if ((($strFullBinary.split(".")).count -ne 2)) { $bValidMask = $false }
		}
	}
	Return $bValidMask
}

function ConvertTo-Binary ($strDecimal)
{
	$strBinary = [Convert]::ToString($strDecimal, 2)
	if ($strBinary.length -lt 8)
	{
		while ($strBinary.length -lt 8)
		{
			$strBinary = "0" + $strBinary
		}
	}
	Return $strBinary
}

function Convert-IPToBinary ($strIP)
{
	$strBinaryIP = $null
	if (Test-IP $strIP)
	{
		$arrSections = @()
		$arrSections += $strIP.split(".")
		foreach ($section in $arrSections)
		{
			if ($null -ne $strBinaryIP)
			{
				$strBinaryIP = $strBinaryIP + "."
			}
			$strBinaryIP = $strBinaryIP + (ConvertTo-Binary $section)
		}
	}
	Return $strBinaryIP
}

Function Convert-SubnetMaskToBinary ($strSubnetMask)
{
	$strBinarySubnetMask = $null
	if (Test-SubnetMask $strSubnetMask)
	{
		$arrSections = @()
		$arrSections += $strSubnetMask.split(".")
		foreach ($section in $arrSections)
		{
			if ($null -ne $strBinarySubnetMask)
			{
				$strBinarySubnetMask = $strBinarySubnetMask + "."
			}
			$strBinarySubnetMask = $strBinarySubnetMask + (ConvertTo-Binary $section)
		}
	}
	Return $strBinarySubnetMask
}

Function Convert-BinaryIPAddress ($BinaryIP)
{
	$FirstSection = [Convert]::ToInt64(($BinaryIP.substring(0, 8)), 2)
	$SecondSection = [Convert]::ToInt64(($BinaryIP.substring(8, 8)), 2)
	$ThirdSection = [Convert]::ToInt64(($BinaryIP.substring(16, 8)), 2)
	$FourthSection = [Convert]::ToInt64(($BinaryIP.substring(24, 8)), 2)
	$strIP = "$FirstSection`.$SecondSection`.$ThirdSection`.$FourthSection"
	Return $strIP
}

function Assert-IntentionallyCreatedPublicResource
{
	param(
		[Parameter(Mandatory)][bool] $ForcePublic
	)

	if (!$ForcePublic)
	{
		Write-Host "##vso[task.complete result=Failed;]You are creating a resource which is, from a network perspective, fully open to the internet. This is NOT recommended. If this was intentional, please pass the -ForcePublic flag."
		throw "You are creating a resource which is, from a network perspective, fully open to the internet. This is NOT recommended. If this was intentional, please pass the -ForcePublic flag."
	}
	else
	{
		Write-Warning "You are creating a resource which is, from a network perspective, fully open to the internet. This is NOT recommended. You've passed the -ForcePublic flag so the pipeline will not break."
	}
}