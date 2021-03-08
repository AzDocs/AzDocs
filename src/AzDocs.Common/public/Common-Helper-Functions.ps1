
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
