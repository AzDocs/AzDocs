
# Fetches the dashed domainname for a given domainname. It also replaces * with "wildcard" (excluding the quotes)
function Get-DashedDomainname
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $DomainName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $dashedDomainName = $DomainName.Replace("-", "--").Replace(".", "-").Replace("*", "wildcard")
    Write-Output $dashedDomainName

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Creating a new array with status code ranges
.DESCRIPTION
Creating a new array with status code ranges
#>
function Get-StatusCodeRanges($existingStatusCodes, $statusCode)
{
    [OutputType([Collections.Generic.List[string]])]
    $statusCodesToSet = [Collections.Generic.List[string]]::new()
    foreach ($item in $existingStatusCodes)
    {
        if ($item -eq $statusCode)
        {
            # als statuscode gelijk is aan het item
            continue
        }

        if ($item.Contains("-"))
        {
            $splittedValue = $item.Split('-')
            $minValue = [int]$splittedValue[0]
            $maxValue = [int]$splittedValue[1]
            $range = $null

            # als de statuscode gelijk is aan het begin en/of eind van de range
            if ($minValue -eq $statusCode)
            {
                $range = Get-Range -min ($statusCode + 1) -max $maxValue
                $statusCodesToSet.Add($range)
                continue
            }
            elseif ($maxValue -eq $statusCode)
            {
                $range = Get-Range -min $minValue -max ($maxValue - 1)
                $statusCodesToSet.Add($range)
                continue
            }

            # als de status code in de range valt
            if (($statusCode -gt $minValue) -and ($statusCode -lt $maxValue))
            {
                # als de statuscode aan het begin en/of eind van de range valt
                if (($maxValue - $statusCode) -eq 1)
                {
                    $range = Get-Range -min $minValue -max ($statusCode - 1)
                    $statusCodesToSet.Add($range)

                    # add the remaining value
                    $statusCodesToSet.Add($maxValue)
                    continue
                }
                elseif (($statusCode - $minValue) -eq 1)
                {
                    $range = Get-Range -min $minValue -max ($statusCode - 1)
                    $statusCodesToSet.Add($range);

                    # add the remaining value
                    $statusCodesToSet.Add($maxValue)
                    continue
                }
                else
                {
                    # als de statuscode in het midden van de range valt
                    $range = Get-Range -min $minValue -max ($statusCode - 1)
                    $statusCodesToSet.Add($range)

                    $range = Get-Range -min ($statusCode + 1) -max $maxValue
                    $statusCodesToSet.Add($range)
                    continue
                }
            }
            else
            {
                # als de statuscode niet in de range valt, maar het item wel "-" heeft
                $statusCodesToSet.Add($item)
            }
        }
        else
        {
            $statusCodesToSet.Add($item)
        }
    }
    
    Write-Output $statusCodesToSet
}

<#
.SYNOPSIS
Helper for Get-StatusCodeRanges
.DESCRIPTION
Helper for Get-StatusCodeRanges
#>
function Get-Range($min, $max)
{
    if ($min -eq $max)
    {
        Write-Output "$min"
    }
    
    Write-Output "$min-$max"
}