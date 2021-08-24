<#
.SYNOPSIS
Helper for asserting CIDR
.DESCRIPTION
Helper for asserting CIDR
#>
function Assert-CIDR
{
    [CmdletBinding()]
    param (
        [Parameter()][string] $CIDR
    )

    if ($CIDR -like '0.0.0.0*')
    {
        throw "CIDR contains 0.0.0.0/0. This will open up any access. This is not allowed."   
    }
}


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
        # Strip TLSv from TlsVersion if it's there (AppGw)
        if ($TlsVersion.StartsWith("TLSv"))
        {
            $TlsVersion = $TlsVersion.Replace("TLSv", "").Replace("_", ".")
            Write-Host "TLS version is $TlsVersion"
        }

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

<#
.SYNOPSIS
Helper for asserting if disabling keyvault purge protection is allowed
.DESCRIPTION
Helper for asserting if disabling keyvault purge protection is allowed
#>
function Assert-ForceDisableKeyvaultPurgeProtection
{
    [CmdletBinding()]
    param (
        [Parameter()][bool] $ForceDisablePurgeProtection, 
        [Parameter()][bool] $KeyvaultPurgeProtectionEnabled
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
    if ($ForceDisablePurgeProtection -eq $false -and $KeyvaultPurgeProtectionEnabled -eq $false)
    {
        Write-Host "##vso[task.complete result=Failed;] You are creating a keyvault for which you want to disable purge protection. This is NOT recommended. If this was intentional, please pass the -ForceDisablePurgeProtection flag."
        throw "You are creating a keyvault for which you want to disable purge protection. This is NOT recommended. If this was intentional, please pass the -ForceDisablePurgeProtection flag."
    }
    else
    {
        Write-Warning "You are creating a keyvault for which you want to disable purge protection. This is NOT recommended."
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Helper for asserting if the ciphersuite has the correct security level
.DESCRIPTION
Helper for asserting if the ciphersuite has the correct security level
#>
function Assert-CipherSuite
{
    [CmdletBinding()]
    param (
        [Parameter()][string] $CipherSuite
    )

    $approvedSecurityLevel = @('recommended', 'secure')
    $response = Invoke-WebRequest "https://ciphersuite.info/api/cs/$CipherSuite/" | ConvertFrom-Json
    
    if (!($approvedSecurityLevel -contains $response.$CipherSuite.security))
    {
        Write-Host "##vso[task.complete result=SucceededWithIssues;]"
        Write-Warning "Please be warned that you are using a ciphersuite ($($CipherSuite)) that has the status $($response.$CipherSuite.security). This is NOT recommended. We advise you to update your cipher suites to one of the recommended ciphers."
    }
}