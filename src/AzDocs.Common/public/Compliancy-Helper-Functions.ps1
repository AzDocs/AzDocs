
<#
.SYNOPSIS
Helper for asserting TLSVersion
.DESCRIPTION
Helper for asserting TLSVersion
#>
function Assert-TLSVersion
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $TlsVersion, 
        [Parameter()][bool] $ForceDisableTls
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Check TlsEnforcement
    $result = Assert-ForceDisableTLS -tlsVersion $TlsVersion -forceDisableTls $ForceDisableTls

    if (!$result)
    {
        # Strip TLS from TlsVersion if it's there
        if ($TlsVersion.StartsWith("TLS"))
        {
            $TlsVersion = $TlsVersion.Replace("TLS", "").Replace("_", ".")
            Write-Host "TLS version is $TlsVersion"
        }
    
        # Setting culture settings
        $culture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
        $culture.NumberFormat.NumberDecimalSeparator = "."
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
    
        # Converting to decimal
        [decimal]$convertedTlsVersion = $null
        $canParse = [decimal]::TryParse($TlsVersion , [ref]$convertedTlsVersion)

        if (!$canParse)
        {
            throw "Cannot parse given TLS version. Please rectify your input: $TlsVersion."
        }

        if ($convertedTlsVersion -lt 1.2)
        {
            Write-Host "##vso[task.complete result=SucceededWithIssues;]"
            Write-Warning "Please be warned that you are using a TLS version that is EOL. Please use TLS 1.2 or higher."
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Helper for asserting if disabling TLS is allowed
.DESCRIPTION
Helper for asserting if disabling TLS is allowed
#>
function Assert-ForceDisableTLS($tlsVersion, $forceDisableTls)
{
    if ($tlsVersion -ne "TLSEnforcementDisabled")
    {
        return $false
    }

    if ($forceDisableTls -eq $false)
    {
        Write-Host "##vso[task.complete result=Failed;] You are creating a resource for which you want to disable TLS. This is NOT recommended. If this was intentional, please pass the -ForceDisableTLS flag."
        throw "You are creating a resource where you want to disable TLS. This is NOT recommended. If this was intentional, please pass the -ForceDisableTLS flag."
    }
    else
    {
        Write-Warning "You are creating a resource for which you want to disable TLS. This is NOT recommended."
        return $true;
    }
}