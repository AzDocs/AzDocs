#region Helper functions

<#
.SYNOPSIS
    Fetch Frontend IP Name for App Gateway
.DESCRIPTION
    Fetch Frontend IP Name for App Gateway
#>
function Get-ApplicationGatewayFrontendIpName
{
    [OutputType([string])]
    param (
        [Alias("SharedServicesResourceGroupName")]
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Alias("GatewayName")]
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $InterfaceType
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $appgateway_frontendips = Invoke-Executable az network application-gateway frontend-ip list --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json
    $ip = $appgateway_frontendips | Where-Object { ![string]::IsNullOrWhiteSpace($_."$($InterfaceType)IpAddress") }

    Write-Output $ip.name

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
    Decodes the given certificate
.DESCRIPTION
    Decodes the given certificate
#>
function ConvertTo-Certificate
{
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param (
        [Parameter(Mandatory)][byte[]] $CertificateBytes
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $p7b = [System.Security.Cryptography.Pkcs.SignedCms]::new()
    $p7b.Decode($CertificateBytes)

    Write-Footer -ScopedPSCmdlet $PSCmdlet

    return $p7b.Certificates[0]
}

<#
.SYNOPSIS
    Fetches a certificate from the given application gateway
.DESCRIPTION
    Fetches a certificate from the given application gateway
#>
function Get-CertificateFromApplicationGateway
(
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $DomainName
)
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    $certlist = Invoke-Executable az network application-gateway ssl-cert list --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName | ConvertFrom-Json
    foreach ($cert in $certlist)
    {
        $subject = ""
        if ($cert.publicCertData)
        {
            $certBytes = [Convert]::FromBase64String($cert.publicCertData)
            $x509 = ConvertTo-Certificate -CertificateBytes $certBytes
            $subject = $x509.Subject
        }
        elseif ($cert.keyVaultSecretId)
        {
            $certValue = (Invoke-Executable az keyvault secret show --id $cert.keyVaultSecretId | ConvertFrom-Json).value
            $certBytes = [Convert]::FromBase64String($certValue)
            $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certBytes)
            $subject = $certificate.Subject
        }
        else
        {
            throw "DeveloperIsAnIdiotException"
        }

        $cn = $subject -replace "(CN=)(.*?),.*", '$2'
        $regexcn = '^' + $cn.Replace('.', '\.').Replace('*', '[A-Za-z0-9\-]+') + '$'
        if ($DomainName -match $regexcn)
        {
            Write-Footer -ScopedPSCmdlet $PSCmdlet
            return $cert.id
        }
    }


    Write-Host "Did not find a certificate that meets the requirements."

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Creates a port on an appgateway
.DESCRIPTION
Creates a port on an appgateway
#>
function New-ApplicationGatewayPort (
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $PortNumber
)
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    Write-Output ((Invoke-Executable az network application-gateway frontend-port create --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name "port_$PortNumber" --port $PortNumber) | ConvertFrom-Json)

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Fetches the portname based on the given portnumber from an given AppGateway
.DESCRIPTION
Fetches the portname based on the given portnumber from an given AppGateway
#>
function Get-ApplicationGatewayPortName (
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][int] $PortNumber )
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    $ports = Invoke-Executable az network application-gateway frontend-port list --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json
    $port = $ports | Where-Object { $_.port -eq $PortNumber }

    # Create port if it does not exist
    if (!$port)
    {
        $result = New-ApplicationGatewayPort -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -PortNumber $PortNumber
        $port = $result.frontendPorts | Where-Object { $_.port -eq $PortNumber }
    }

    if ($port)
    {
        Write-Footer -ScopedPSCmdlet $PSCmdlet
        return $port.name
    }
    else
    {
        throw "Port could not be found"
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
    Fetches the soft-deleted certificates from Keyvault
.DESCRIPTION
    Fetches the soft-deleted certificates from Keyvault
#>
function Get-SoftDeletedCertificateFromKeyvault(
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $DomainName,
    [Parameter(Mandatory)][string] $ExpectedCertificateThumbprint )
{
    Write-Header -ScopedPSCmdlet $PSCmdlet
    
    $softDeletedCertificateFound = $null
    # Check if there are certificates in soft-deleted state
    $softDeletedCertificates = Invoke-Executable az keyvault certificate list-deleted --vault-name $KeyvaultName --query="[?x509ThumbprintHex=='$ExpectedCertificateThumbprint']" | ConvertFrom-Json
    if ($softDeletedCertificates -and $softDeletedCertificates.Length -eq 1)
    {
        Write-Host "Found soft-deleted certificate."
        $softDeletedCertificateFound = $softDeletedCertificates[0]
    }
    elseif ($softDeletedCertificates -and $softDeletedCertificates.Length -gt 1)
    {
        throw "Multiple soft-deleted certificates were found with the same thumbprint."
    }

    if (!$softDeletedCertificateFound)
    {
        $softDeletedCertList = Invoke-Executable az keyvault certificate list-deleted --vault-name $KeyvaultName --include-pending $false | ConvertFrom-Json
        if ($softDeletedCertList)
        {
            foreach ($cert in $softDeletedCertList)
            {
                $subject = (Invoke-Executable az keyvault certificate show-deleted --id $cert.recoveryId | ConvertFrom-Json).policy.x509CertificateProperties.subject
        
                $cn = $subject -replace '(CN=)(.*?),.*', '$2'
                $regexcn = '^' + $cn.replace('.', '\.').Replace('*', '[A-Za-z0-9\-]+') + '$'
                if ($DomainName -match $regexcn)
                {
                    Write-Host "Found soft-deleted certificate."
                    $softDeletedCertificateFound = $cert
                }
            }
        }
    }
   
    Write-Output $softDeletedCertificateFound

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
    Fetches the certificate from Keyvault
.DESCRIPTION
    Fetches the certificate from Keyvault
#>
function Get-CertificateFromKeyvault (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $DomainName,
    [Parameter(Mandatory)][string] $ExpectedCertificateThumbprint )
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    if ($ExpectedCertificateThumbprint)
    {
        $certificates = Invoke-Executable az keyvault certificate list --vault-name $KeyvaultName --query="[?x509ThumbprintHex=='$ExpectedCertificateThumbprint']" | ConvertFrom-Json
        if ($certificates -and $certificates.Length -eq 1)
        {
            Write-Footer -ScopedPSCmdlet $PSCmdlet
            return $certificates[0]
        }
        elseif ($certificates -and $certificates.Length -gt 1)
        {
            throw "Multiple certs with the same thumbprint found."
        }
    }

    $certlist = Invoke-Executable az keyvault certificate list --vault-name $KeyvaultName --include-pending false | ConvertFrom-Json

    if (!$certlist)
    {
        Write-Footer -ScopedPSCmdlet $PSCmdlet
        return $null
    }

    foreach ($cert in $certlist)
    {
        $subject = (Invoke-Executable az keyvault certificate show --id $cert.id | ConvertFrom-Json).policy.x509CertificateProperties.subject

        $cn = $subject -replace '(CN=)(.*?),.*', '$2'
        $regexcn = '^' + $cn.replace('.', '\.').Replace('*', '[A-Za-z0-9\-]+') + '$'
        if ($DomainName -match $regexcn)
        {
            Write-Footer -ScopedPSCmdlet $PSCmdlet
            return $cert
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
    return $null
}

# Grants the current user permissions on keyvault to work with the contents
function Grant-MePermissionsOnKeyvault (
    [Parameter(Mandatory)][string] $KeyvaultResourceGroupName,
    [Parameter(Mandatory)][string] $KeyvaultName)
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    $identityId = (Invoke-Executable az account show | ConvertFrom-Json).user.name
    Invoke-Executable az keyvault set-policy --name $KeyvaultName --certificate-permissions get list create update import delete recover --key-permissions get list create update import recover --secret-permissions get list set recover --storage-permissions get list update set recover --spn $identityId --resource-group $KeyvaultResourceGroupName | Out-Null

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

# Adds a certificate to Keyvault
function Add-CertificateToKeyvault (
    [Parameter(Mandatory)][string] $KeyvaultName,
    [Parameter(Mandatory)][string] $CertificateName,
    [Parameter(Mandatory)][string] $CertificatePath,
    [Parameter(Mandatory)][string] $CertificatePassword,
    [Parameter(Mandatory)][string] $CommonName )
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    Invoke-Executable az keyvault certificate import --vault-name $KeyvaultName --name $CertificateName --file $CertificatePath --password $CertificatePassword --tags CommonName=$CommonName

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

# Adds a certificate from Keyvault to the AppGateway
function Add-KeyvaultCertificateToApplicationGateway
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $KeyvaultName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $KeyvaultCertificateName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Get the keyvault-secret-id of the certificate in the Keyvault
    $keyvaultSecretId = Invoke-Executable az keyvault secret show --name $KeyvaultCertificateName --vault-name $KeyvaultName --query=id
    # Upload an SSL certificate using key-vault-secret-id of a KeyVault Secret
    Invoke-Executable az network application-gateway ssl-cert create --gateway-name $ApplicationGatewayName --name $KeyvaultCertificateName --key-vault-secret-id $keyvaultSecretId --resource-group $ApplicationGatewayResourceGroupName

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}


# Fetches the common name for a certificate (pfx)
function Get-CommonnameFromCertificate
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CertificatePath,
        [Parameter(Mandatory)][string] $CertificatePassword
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $certificate = Get-Certificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword

    if (!$certificate.Subject)
    {
        throw 'Could not find a subject for this certificate'
    }

    $subject = $certificate.Subject
    Write-Host "Certificate subject: $subject"

    $cn = $subject -replace "(CN=)(.*?),.*", '$2'
    $cn = $cn -replace "CN=", ""

    write-output $cn

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Get-Certificate
{
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param (
        [Parameter(Mandatory)][string] $CertificatePath,
        [Parameter(Mandatory)][string] $CertificatePassword
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    [System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($CertificatePath, $CertificatePassword);
    if (!$certificate)
    {
        throw "Could not fetch the certificate $CertificatePath"
    }
    Write-Output $certificate

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Test-ShouldReplaceCertificate(
    [Parameter(Mandatory)][string] $CertificatePath,
    [Parameter(Mandatory)][string] $CertificatePassword,
    [Parameter()][PSObject] $KeyvaultCertificate
)
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    if (!$KeyvaultCertificate)
    {
        return $false
    }

    if ($CertificatePath -and (Test-Path $CertificatePath))
    {
        Write-Host "Let's see if we need to upload the source certificate (because it is newer)."
        $sourceCertificate = Get-Certificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword
        $shouldReplaceCertificate = $sourceCertificate.Thumbprint -ne $KeyvaultCertificate.x509ThumbprintHex -and $sourceCertificate.NotAfter -gt $KeyvaultCertificate.attributes.expires -and (Get-Date) -gt $sourceCertificate.notBefore
        Write-Output $shouldReplaceCertificate
        Write-Footer -ScopedPSCmdlet $PSCmdlet
    }

    return $false
}

# Check if the domain (backend) is healthy
function Test-ApplicationGatewayBackendIsHealthy
{
    [OutputType([boolean])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $BackendDomainName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Fetch Backends from Azure
    $backends = (Invoke-Executable az network application-gateway show-backend-health --name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --query backendAddressPools[].backendHttpSettingsCollection[].servers[] | ConvertFrom-Json)

    # Select the backend we search
    $backend = $backends | Where-Object -Property address -eq $BackendDomainName

    # Check if the backend is present
    if (!$backend)
    {
        Write-Footer -ScopedPSCmdlet $PSCmdlet
        # Backend is not present
        throw "Could not find specified backend"
    }

    # Check if backend is healthy
    $backendHealthy = $backend.health -eq "Healthy"
    Write-Output @{ BackendIsHealthy = $backendHealthy; HealthProbeLog = $backend.healthProbeLog }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

# Fetches the User Identity which is used by the AppGateway
function Get-UserIdentityForGateway
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $userIdentity = (Invoke-Executable az identity show --name "useridentity-$ApplicationGatewayName" --resource-group $ApplicationGatewayResourceGroupName -AllowToFail)
    Write-Output $userIdentity

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

# Make sure our AppGateway User Identity is assigned to keyvault (the process will break if this isn't the case)
function Grant-ApplicationGatewayPermissionsToKeyvault
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $KeyvaultName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $userIdentity = Invoke-Executable az network application-gateway identity show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName -AllowToFail | ConvertFrom-Json
    $principalId = $userIdentity.userAssignedIdentities.psobject.Properties.value.principalId
    $userIdentityAssigned = $userIdentity.userAssignedIdentities.psobject.Properties.Name -contains "useridentity-$ApplicationGatewayName"
    Write-Host "AppGW Identity before assigning: $principalId"
    if (!$principalId -or !$userIdentityAssigned)
    {
        $userIdentity = Get-UserIdentityForGateway -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName | ConvertFrom-Json
        if (!$userIdentity)
        {
            #create user assigned identity
            $userIdentity = Invoke-Executable az identity create --name "useridentity-$ApplicationGatewayName" --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json
        }
        $principalId = $userIdentity.principalId
        $userIdentityId = $userIdentity.id

        # Assign User Identity to Application Gateway
        Write-Host "Assigning User Identity to App Gateway with User ID: $userIdentityId"
        Invoke-Executable az network application-gateway identity assign --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --identity $userIdentityId | Out-Null
    }
    Write-Host "UserIdentity Principal ID: $principalId"
    Invoke-Executable az keyvault set-policy --name $KeyvaultName --object-id $principalId --certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update --key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey --secret-permissions backup delete get list purge recover restore set --storage-permissions backup delete deletesas get getsas list listsas purge recover regeneratekey restore set setsas update | Out-Null

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

#endregion

#region Rewrite rule functions

<#
.SYNOPSIS
Get rewrite rule set
.DESCRIPTION
Get rewrite rule set
#>
function Get-RewriteRuleSet
{
    [OutputType([PsCustomObject])]
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $RewriteRuleSetName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $existingRewriteRulesets = Invoke-Executable az network application-gateway rewrite-rule set list --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName | ConvertFrom-Json 
    $rewriteRuleSet = $existingRewriteRulesets | Where-Object Name -eq $RewriteRuleSetName

    Write-Output $rewriteRuleSet

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Create a new rewrite rule set
.DESCRIPTION
Create a new rewrite rule set
#>
function New-RewriteRuleSet
{
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $RewriteRuleSetName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
    
    if (!(Get-RewriteRuleSet -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $RewriteRuleSetName))
    {
        Write-Host "Rewrite set does not exist yet, creating: '$RewriteRuleSetName' in gateway '$ApplicationGatewayName'"
        Invoke-Executable az network application-gateway rewrite-rule set create --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name $RewriteRuleSetName
    }
    else
    {
        Write-Host "Rewrite rule set exists : $RewriteRuleSetName"
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Assign a rewrite rule set to a request routing rule
.DESCRIPTION
Assign a rewrite rule set to a request routing rule
#>
function New-RewriteRuleSetAssignment
{
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $RewriteRuleSetName,
        [Parameter(Mandatory)][string] $ApplicationGatewayRequestRoutingRuleName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $rewriteRuleSet = Get-RewriteRuleSet -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $RewriteRuleSetName
    if (!$rewriteRuleSet)
    {
        Write-Host 'Rewrite rule set has not been found and cannot be assigned.'
    }
    else
    {
        # check if rewrite rule set has already been attached
        $rewriteSetId = (Invoke-Executable az network application-gateway rule show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name $ApplicationGatewayRequestRoutingRuleName | ConvertFrom-Json).rewriteRuleSet.id
        if ($rewriteSetId -eq $rewriteRuleSet.id)
        {
            Write-Host "The rewrite rule has already been assigned. Continueing"
        }
        else
        {
            Write-Host 'Assigning rewrite-rule set'
            Invoke-Executable az network application-gateway rule update --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name $ApplicationGatewayRequestRoutingRuleName --rewrite-rule-set $RewriteRuleSetName
        }
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Validate if there were any changes to a rewrite rule and its condition
.DESCRIPTION
Validate if there were any changes to a rewrite rule and its condition
#>
function Confirm-RewriteRule
{
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)][PSCustomObject] $currentRule, 
        [Parameter(Mandatory)][PSCustomObject] $newRule
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    if ($null -eq $currentRule.HeaderName -or $null -eq $currentRule.HeaderValue -or $null -eq $currentRule.ConditionVariable -or $null -eq $currentRule.ConditionPattern -or $null -eq $currentRule.ConditionNegate)
    {
        if ($null -eq $newRule.HeaderName -or $null -eq $newRule.HeaderValue -or $null -eq $newRule.ConditionVariable -or $null -eq $newRule.ConditionPattern -or $null -eq $newRule.ConditionNegate)
        {
            throw 'Missing one of the propertynames to check on: HeaderName, HeaderValue, ConditionVariable, ConditionPattern and ConditionNegate'
        }
    }

    if ($currentRule.HeaderName -ne $newRule.HeaderName -or $currentRule.HeaderValue -ne $newRule.HeaderValue -or $currentRule.ConditionVariable -ne $newRule.ConditionVariable -or $currentRule.ConditionPattern -ne $newRule.ConditionPattern -or $currentRule.ConditionNegate -ne $newRule.ConditionNegate)
    {
        Write-Host "Values have changed for the rule. Updating."
        Write-Output $true
    }
    else
    {
        Write-Host "No values have changed for the rule. Continueing."
        Write-Output $false
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Remove rewrite rule from rewrite rule set
.DESCRIPTION
Remove rewrite rule from rewrite rule set
#>
function Remove-RewriteRule
{
    param (
        [Parameter(Mandatory)][String] $ApplicationGatewayName,
        [Parameter(Mandatory)][String] $ApplicationGatewayResourceGroupName, 
        [Parameter(Mandatory)][String] $RewriteRuleSetName,
        [Parameter(Mandatory)][String] $RewriteRuleName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $rewriteRuleSet = Get-RewriteRuleSet -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $RewriteRuleSetName
    # check if rewrite rule set exists
    if (!$rewriteRuleSet)
    {
        throw 'Rewrite rule set does not exist.'
    }

    # check if rewrite rule exists
    $rewriteRule = $rewriteRuleSet.rewriteRules | Where-Object Name -eq $RewriteRuleName
    if (!$rewriteRule)
    {
        Write-Host "Rewrite rule $RewriteRuleName does not exist or has already been removed. Continueing."
    }
    else
    {
        Write-Host "Removing rewrite rule from set with name $RewriteRuleName"
        Invoke-Executable az network application-gateway rewrite-rule delete --gateway-name $ApplicationGatewayName --name $RewriteRuleName --resource-group $ApplicationGatewayResourceGroupName --rule-set-name $RewriteRuleSetName
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

<#
.SYNOPSIS
Creates and adds a new rewrite rule including condition
.DESCRIPTION
Creates and adds a new rewrite rule including condition
#>
function New-RewriteRuleAndCondition
{
    param (
        [Parameter(Mandatory)][String] $ApplicationGatewayName,
        [Parameter(Mandatory)][String] $ApplicationGatewayResourceGroupName, 
        [Parameter(Mandatory)][String] $RewriteRuleSetName,
        [Parameter(Mandatory)][String] $RewriteRuleName,
        [Parameter(Mandatory)][String] $HeaderName,
        [Parameter(Mandatory)][AllowEmptyString()][String] $HeaderValue,
        [Parameter(Mandatory)][String] $ConditionVariable,
        [Parameter(Mandatory)][String] $ConditionPattern,
        [Parameter(Mandatory)][Boolean] $ConditionNegate
    )
    
    Write-Header -ScopedPSCmdlet $PSCmdlet

    $rewriteRuleSet = Get-RewriteRuleSet -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $RewriteRuleSetName
    # Check if rewrite rule set exists
    if (!$rewriteRuleSet)
    {
        throw 'Rewrite rule set does not exist.'
    }

    $rewriteRule = $rewriteRuleSet.rewriteRules | Where-Object Name -eq $RewriteRuleName
    if (!$rewriteRule)
    {
        $needToRewrite = $true;
    }
    else
    {
        Write-Host "Verifying rule: '$($rewriteRule.Name)'"
        
        $currentRule = [PSCustomObject]@{
            HeaderName        = $rewriteRule.actionSet.responseHeaderConfigurations.headerName
            HeaderValue       = $rewriteRule.actionSet.responseHeaderConfigurations.headerValue
            ConditionVariable = $rewriteRule.conditions.variable
            ConditionPattern  = $rewriteRule.conditions.pattern
            ConditionNegate   = $rewriteRule.conditions.negate
        }
        $newRule = [PsCustomObject]@{
            HeaderName        = $HeaderName
            HeaderValue       = $HeaderValue
            ConditionVariable = $ConditionVariable
            ConditionPattern  = $ConditionPattern 
            ConditionNegate   = $ConditionNegate
        }

        # Validate if anything changed in the rewrite rule
        $needToRewrite = Confirm-RewriteRule -currentRule $currentRule -newRule $newRule 
    }

    # Create new rewrite rules + conditions
    if ($needToRewrite)
    {
        Invoke-Executable az network application-gateway rewrite-rule create --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --rule-set-name  $RewriteRuleSetName --name $RewriteRuleName --response-headers "$($HeaderName)=$($HeaderValue)"
        Invoke-Executable az network application-gateway rewrite-rule condition create --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --rule-set-name  $RewriteRuleSetName --rule-name $RewriteRuleName --variable "$($ConditionVariable)" --negate $ConditionNegate --pattern `"$ConditionPattern`"
    }
    
    Write-Footer -ScopedPSCmdlet $PSCmdlett
}

#endregion

#region Main function

function New-ApplicationGatewayRule
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $DashedDomainName,
        [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $ApplicationGatewayRuleType,
        [Parameter()][string] $ApplicationGatewayRuleUrlPathMapId
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $optionalParameters = @()
    if ($ApplicationGatewayRuleUrlPathMapId)
    {
        $optionalParameters += "--url-path-map", $ApplicationGatewayRuleUrlPathMapId
    }

    # Add the routing rule
    $gatewayRule = Invoke-Executable -AllowToFail az network application-gateway rule show --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name "$DashedDomainName-httpsrule" | ConvertFrom-Json
    if (!$gatewayRule)
    {
        Write-Host "Creating routing rule"
        $lastPriority = [nullable[int]](Invoke-Executable az network application-gateway rule list --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --query "[? priority!=null]|max_by([].{Priority:priority}, &Priority) | Priority")
        if($lastPriority -ne $null){
            $priority = $lastPriority + 10
            $optionalParameters += "--priority", $priority
        }
        Invoke-Executable az network application-gateway rule create --gateway-name $ApplicationGatewayName --name "$DashedDomainName-httpsrule" --http-listener "$DashedDomainName-httpslistener" --address-pool "$DashedDomainName-httpspool" --http-settings "$DashedDomainName-httpssettings" --rule-type $ApplicationGatewayRuleType --resource-group $ApplicationGatewayResourceGroupName @optionalParameters | Out-Null
        Write-Host "Created routing rule"
    }
    else
    {
        Write-Host "Updating the existing routing rule"
        Invoke-Executable az network application-gateway rule update --gateway-name $ApplicationGatewayName --name "$DashedDomainName-httpsrule" --http-listener "$DashedDomainName-httpslistener" --address-pool "$DashedDomainName-httpspool" --http-settings "$DashedDomainName-httpssettings" --rule-type $ApplicationGatewayRuleType --resource-group $ApplicationGatewayResourceGroupName @optionalParameters | Out-Null
        Write-Host "Updated the existing routing rule"
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Confirm-ApplicationGatewayPathBasedRoutingRule
{
    [CmdletBinding()]
    param (
        [Parameter()][string] $ApplicationGatewayRuleDefaultIngressDomainNameDashed,
        [Parameter()][string] $ApplicationGatewayRulePath
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
        
    Write-Host "Checking if ApplicationGatewayPath are configured correctly"
    if (!$ApplicationGatewayRulePath.StartsWith("/"))
    {
        throw "The following path '$ApplicationGatewayRulePath' does not start with a '/'. This is required. Please fix the path and try again."
    }
    Write-Host "The ApplicationGatewayRulePath are configured correctly."
   
    Write-Host "Checking if the specified default address pools/httpsettings exist"
    $defaultAddressPool = Invoke-Executable az network application-gateway address-pool show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$ApplicationGatewayRuleDefaultIngressDomainNameDashed-httpspool"
    $defaultHttpSetting = Invoke-Executable az network application-gateway http-settings show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$ApplicationGatewayRuleDefaultIngressDomainNameDashed-httpssettings"
    if (!$defaultAddressPool -or !$defaultHttpSetting)
    {
        throw "The default address pool or the default http setting for the Application Gateway Rule does not exist. Please create the entrypoint for the default application."
    }

    Write-Host "The specified default address pools/httpsettings exists."
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Get-ApplicationGatewayHttpRules
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $DashedDomainName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $gatewayRules = @()
    $httpGatewayRule = (Invoke-Executable -AllowToFail az network application-gateway rule show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$DashedDomainName-httprule" | ConvertFrom-Json).id
    $httpsGatewayRule = (Invoke-Executable -AllowToFail az network application-gateway rule show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$DashedDomainName-httpsrule" | ConvertFrom-Json).id
    if ($httpGatewayRule)
    {
        $gatewayRules += $httpGatewayRule
    }
    if ($httpsGatewayRule)
    {
        $gatewayRules += $httpsGatewayRule
    }

    Write-Output $gatewayRules
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Get-ApplicationGatewayListeners
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $DashedDomainName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $listeners = @()
    $httpListenerResourceId = Invoke-Executable -AllowToFail az network application-gateway http-listener show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$DashedDomainName-httplistener" | ConvertFrom-Json
    $httpsListenerResourceId = Invoke-Executable -AllowToFail az network application-gateway http-listener show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$DashedDomainName-httpslistener" | ConvertFrom-Json
    if ($httpsListenerResourceId)
    {
        $listeners += $httpsListenerResourceId
    }
    if ($httpListenerResourceId)
    {
        $listeners += $httpListenerResourceId
    }

    Write-Output $listeners

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Remove-ApplicationGatewayEntrypoint
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $IngressDomainName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Get the dashed version of the domainname to use as name for multiple app gateway components
    Write-Host "Fetching dashed domainname"
    $dashedDomainName = Get-DashedDomainname -DomainName $IngressDomainName
    Write-Host "Dashed domainname: $dashedDomainName"

    # Remove rules if exists
    $gatewayRulesFound = Get-ApplicationGatewayHttpRules -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -DashedDomainName $dashedDomainName
    if ($gatewayRulesFound)
    {
        Write-Host "Found gateway rules for $dashedDomainName. Removing.."
        foreach ($gatewayRule in $gatewayRulesFound)
        {
            Write-Host "Deleting gateway rule $gatewayRule."
            Invoke-Executable az network application-gateway rule delete --ids $gatewayRule
        }
    }

    # Remove redirect configuration for HTTP and HTTPS if exists
    $httpRedirectConfigResourceId = (Invoke-Executable -AllowToFail az network application-gateway redirect-config show --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpredirector" --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
    if ($httpRedirectConfigResourceId)
    {
        Write-Host "Found http redirect for $dashedDomainName. Removing.."
        Invoke-Executable az network application-gateway redirect-config delete --ids $httpRedirectConfigResourceId
    }

    # Remove listener entrypoint for HTTP and HTTPS if exists
    $listenersFound = Get-ApplicationGatewayListeners -DashedDomainName $dashedDomainName -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName
    if ($listenersFound)
    {
        Write-Host "Found HTTP/HTTPS Listener for $dashedDomainName. Removing.."
        foreach ($listenerFound in $listenersFound)
        {
            Write-Host "Deleting listener ${listenerFound.name}."
            Invoke-Executable az network application-gateway http-listener delete --ids $listenerFound.id
            if ($listenerFound.sslCertificate)
            {
                Write-Host "Searching for ssl certificate attached to listener."
                $sslCertFound = Invoke-Executable -AllowToFail az network application-gateway ssl-cert show --ids $listenerFound.sslCertificate.id | ConvertFrom-Json
                $sslCertIsUsed = $false
                if ($sslCertFound)
                {
                    Write-Host "Checking if certificate is being used by other entrypoints.."
                    $listenersCertificates = (Invoke-Executable az network application-gateway http-listener list --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).sslCertificate
                    foreach ($certificate in $listenersCertificates)
                    {
                        if ($certificate.id -eq $sslCertFound.id)
                        {
                            Write-Host 'Certificate is being used by other entrypoints. Skipping removing from gateway and keyvault.'
                            $sslCertIsUsed = $true
                            break
                        }
                    }
            
                    if (!$sslCertIsUsed)
                    {
                        Write-Host "Certificate is not being used by other entrypoints. Removing from gateway and keyvault.."
            
                        Write-Host "Found SSL Certificate for $dashedDomainName. Removing.."
                        Invoke-Executable az network application-gateway ssl-cert delete --ids $sslCertFound.id

                        Write-Host "Granting permissions on keyvault for executing user"
                        # Grant the current logged in user (service principal) rights to modify certificates in the keyvault (for uploading & fetching the certificate)
                        Grant-MePermissionsOnKeyvault -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName -KeyvaultName $CertificateKeyvaultName
                        Write-Host "Granted permissions on keyvault for executing user"
            
                        # Removing from keyvault
                        $keyvaultCertificate = Invoke-Executable az keyvault certificate show --vault-name $CertificateKeyvaultName --name $sslCertFound.name
                        if ($keyvaultCertificate)
                        {
                            Write-Host "Removing certificate from keyvault."
                            Invoke-Executable az keyvault certificate delete --name $sslCertFound.name --vault-name $CertificateKeyvaultName
                        }            
                    }
                }
            }            
        }
    }
   
    # Remove backend pool if exists
    $backendPoolResourceId = (Invoke-Executable -AllowToFail az network application-gateway address-pool show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$dashedDomainName-httpspool" | ConvertFrom-Json).id
    if ($backendPoolResourceId)
    {
        Write-Host "Found backend pool for $dashedDomainName. Removing.."
        Invoke-Executable az network application-gateway address-pool delete --ids $backendPoolResourceId
    }

    # Remove https settings if exists
    $httpsSettingResourceId = (Invoke-Executable -AllowToFail az network application-gateway http-settings show --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --name "$dashedDomainName-httpssettings" | ConvertFrom-Json).id
    if ($httpsSettingResourceId)
    {
        Write-Host "Found HTTPS Settings for $dashedDomainName. Removing.."
        Invoke-Executable az network application-gateway http-settings delete --ids $httpsSettingResourceId
    }

    # Remove health probe if exists
    $healthProbeResourceId = (Invoke-Executable -AllowToFail az network application-gateway probe show --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpsprobe" --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
    if ($healthProbeResourceId)
    {
        Write-Host "Found health probe for $dashedDomainName. Removing.."
        Invoke-Executable az network application-gateway probe delete --ids $healthProbeResourceId
    }
   
    # Remove rewrite sets if exists
    $rewriteRuleSetResourceId = (Invoke-Executable -AllowToFail az network application-gateway rewrite-rule set show --gateway-name $ApplicationGatewayName --name "$dashedDomainName-https-rewriteset" --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
    if ($rewriteRuleSetResourceId)
    {
        Write-Host "Found rewrite ruleset for $dashedDomainName. Removing.."
        Invoke-Executable az network application-gateway rewrite-rule set delete --ids $rewriteRuleSetResourceId
    }

    Write-Host "Removed every gateway component for $dashedDomainName"
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function New-ApplicationGatewayEntrypoint
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CertificatePath,
        [Parameter(Mandatory)][string] $CertificatePassword,
        [Parameter(Mandatory)][string] $IngressDomainName,
        [Parameter(Mandatory)][string] $ApplicationGatewayName,
        [Parameter(Mandatory)][ValidateSet("Private", "Public")][string] $ApplicationGatewayFacingType,
        [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultName,
        [Parameter()][string] $BackendDomainName,
        [Parameter(Mandatory)][string] $HealthProbeUrlPath,
        [Parameter()][string] $HealthProbeDomainName,
        [Parameter()][int] $HealthProbeIntervalInSeconds = 60,
        [Parameter()][int] $HealthProbeNumberOfTriesBeforeMarkedDown = 2,
        [Parameter()][int] $HealthProbeTimeoutInSeconds = 20,
        [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $HealthProbeProtocol = "HTTPS",
        [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $HttpsSettingsRequestToBackendProtocol = "HTTPS",
        [Parameter()][ValidateRange(0, 65535)][int] $HttpsSettingsRequestToBackendPort = 443,
        [Parameter()][ValidateSet("Disabled", "Enabled")][string] $HttpsSettingsRequestToBackendCookieAffinity = "Disabled",
        [Parameter()][int] $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds = 0,
        [Parameter()][int] $HttpsSettingsRequestToBackendTimeoutInSeconds = 30,
        [Parameter()][string] $HttpsSettingsCustomRootCertificateFilePath,
        [Parameter()][string] $HealthProbeMatchStatusCodes = "200-399",
        [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $ApplicationGatewayRuleType,
        [Parameter()][string] $ApplicationGatewayRuleDefaultIngressDomainName, 
        [Parameter()][string] $ApplicationGatewayRulePath
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Check if the gateway rule type is PathBased, if the parameters are correct
    if ($ApplicationGatewayRuleType -eq 'PathBasedRouting')
    {
        if (!$ApplicationGatewayRuleDefaultIngressDomainName -or !$ApplicationGatewayRulePath)
        {
            throw 'You have decided to use PathBasedRouting for your ApplicationGatewayRuleType. Please specify the parameters ApplicationGatewayRuleDefaultIngressDomainName and ApplicationGatewayRulePath'
        }

        Write-Host "Getting dashed ApplicationGatewayRuleDefaultIngressDomainName"
        $applicationGatewayRuleDefaultIngressDomainNameDashed = Get-DashedDomainname -DomainName $ApplicationGatewayRuleDefaultIngressDomainName
        Write-Host "ApplicationGatewayRuleDefaultIngressDomainName: $applicationGatewayRuleDefaultIngressDomainNameDashed"
        Confirm-ApplicationGatewayPathBasedRoutingRule -ApplicationGatewayRuleDefaultIngressDomainNameDashed $applicationGatewayRuleDefaultIngressDomainNameDashed -ApplicationGatewayRulePath $ApplicationGatewayRulePath
    }

    # Fetch the commonname for the given certificate
    Write-Host "Fetching commonname"
    $CommonName = Get-CommonnameFromCertificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword
    Write-Host "Commonname: $CommonName"

    # Get the dashed version of the common name to use as the certname
    Write-Host "Fetching certificatename"
    $CertificateName = Get-DashedDomainname -DomainName $CommonName
    Write-Host "Certificatename: $CertificateName"

    # Get the dashed version of the domainname to use as name for multiple app gateway components
    Write-Host "Fetching dashed domainname"
    $dashedDomainName = Get-DashedDomainname -DomainName $IngressDomainName
    Write-Host "Dashed domainname: $dashedDomainName"

    # Fetch the name of the Frontend IP based on the interface type (public or private)
    Write-Host "Fetching Frontend IPname"
    $frontendIpName = Get-ApplicationGatewayFrontendIpName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -InterfaceType $ApplicationGatewayFacingType
    Write-Host "Frontend IPname: $frontendIpName"

    # Fetch the portname based on the portnumber
    Write-Host "Fetching portname for HTTPS"
    $portName = Get-ApplicationGatewayPortName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -PortNumber 443
    Write-Host "Portname: $portName"

    Write-Host "Granting permissions on keyvault for executing user"
    # Grant the current logged in user (service principal) rights to modify certificates in the keyvault (for uploading & fetching the certificate)
    Grant-MePermissionsOnKeyvault -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName -KeyvaultName $CertificateKeyvaultName
    Write-Host "Granted permissions on keyvault for executing user"

    Write-Host "Assigning Application Gateway identity to Keyvault"
    # Make sure our AppGateway User Identity is assigned to keyvault (the process will break if this isn't the case)
    Grant-ApplicationGatewayPermissionsToKeyvault -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -KeyvaultName $CertificateKeyvaultName
    Write-Host "Application Gateway identity assigned to Keyvault"
  
    # Check if there are network rules present for the keyvault
    $keyvaultNetworkRules = (Invoke-Executable az keyvault network-rule list --name $CertificateKeyvaultName | ConvertFrom-Json).virtualNetworkRules
    
    if ($keyvaultNetworkRules)
    {
        Write-Host "Whitelisting agent ip on keyvault.."
        # Get root path and make sure the right provider is registered
        $RootPath = (Get-Item $PSScriptRoot).Parent.Parent
        & "$RootPath\Keyvault\Add-Network-Whitelist-to-Keyvault.ps1" -KeyvaultName $CertificateKeyvaultName -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName
    }
    
    # Fetch the certificate from the AppGateway if it exists
    Write-Host "Fetching AppGateway certificate"
    $appgatewayCertificate = Get-CertificateFromApplicationGateway -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -DomainName $IngressDomainName
    Write-Host "AppGateway Certificate: $appgatewayCertificate"

    # Fetch the certificate from Keyvault if it exists
    Write-Host "Fetching Keyvault certificate"
    $sourceCertificate = Get-Certificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword
    $keyvaultCertificate = Get-CertificateFromKeyvault -KeyvaultName $CertificateKeyvaultName -DomainName $IngressDomainName -ExpectedCertificateThumbprint $sourceCertificate.Thumbprint
    if ($keyvaultCertificate)
    {
        Write-Host "Keyvault Certificate: $($keyvaultCertificate.id)"
        Write-Host "Keyvault Certificate Notbefore: $($keyvaultCertificate.attributes.notBefore)"
        Write-Host "Keyvault Certificate Notafter: $($keyvaultCertificate.attributes.expires)"
    }
    else
    {
        Write-Host "Keyvault certificate not found."
        Write-Host "Checking if keyvault certificate exists in soft-deleted state."

        $softDeletedCertificate = Get-SoftDeletedCertificateFromKeyvault -KeyvaultName $CertificateKeyvaultName -DomainName $IngressDomainName -ExpectedCertificateThumbprint $sourceCertificate.Thumbprint
        if ($softDeletedCertificate)
        {
            Write-Host "Found soft-deleted certificate. Recovering.."
            Invoke-Executable az keyvault certificate recover --id $softDeletedCertificate.recoveryId

            # Find restored certificate in keyvault
            $keyvaultCertificate = Get-CertificateFromKeyvault -KeyvaultName $CertificateKeyvaultName -DomainName $IngressDomainName -ExpectedCertificateThumbprint $sourceCertificate.Thumbprint
        }
        else
        {
            Write-Host "Did not find a soft-deleted certificate. Continueing.."
        }
    }

    # Check if our source (Azure DevOps) certificate is newer than what we have in Keyvault (and therefore AppGw)
    $shouldReplaceCertificateWithSourceCertificate = Test-ShouldReplaceCertificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -KeyvaultCertificate $keyvaultCertificate
    if ($shouldReplaceCertificateWithSourceCertificate)
    {
        Write-Host "We should replace the certificate on the AppGw & Keyvault because the source certificate is renewed."
    }

    Write-Host "Checking if/where certificates exists and if we should replace it..."
    # Check if the certificate exists in the gateway
    if (!$appgatewayCertificate -or $shouldReplaceCertificateWithSourceCertificate)
    {
        Write-Host "AppGateway cert not found or should be replaced."
        # Check if the certificate exists in the keyvault
        if (!$keyvaultCertificate -or !$keyvaultCertificate.id -or $shouldReplaceCertificateWithSourceCertificate)
        {
            Write-Host "KeyVault cert not found or should be replaced."
            # Check if the certificate exists on disk (if not, stop the process)
            if (!$CertificatePath -or !(Test-Path $CertificatePath))
            {
                Write-Error "There is no source certificate found (Azure DevOps)."
            }
            # Add the certificate to keyvault if its not there yet
            $keyvaultCertificate = Add-CertificateToKeyvault -KeyvaultName $CertificateKeyvaultName -CertificateName $CertificateName -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -CommonName $CommonName
            Write-Host "Cert added/replaced to keyvault"
        }

        Write-Host "AppGatewayCertificate before adding keyvault certificate to application gateway $appgatewayCertificate"
        # Add the certificate to the AppGateway if its not there yet
        Add-KeyvaultCertificateToApplicationGateway -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -KeyvaultName $CertificateKeyvaultName -ApplicationGatewayName $ApplicationGatewayName -KeyvaultCertificateName $CertificateName 
       
        $appgatewayCertificate = (Invoke-Executable az network application-gateway ssl-cert show --gateway-name $ApplicationGatewayName --name $CertificateName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
        Write-Host "Cert added/replaced to appgateway"
    }

    # Check if there were network rules present for the keyvault
    if ($keyvaultNetworkRules)
    {
        Write-Host "Removing whitelist agent ip from keyvault"
        # Get root path and make sure the right provider is registered
        $RootPath = (Get-Item $PSScriptRoot).Parent.Parent
        & "$RootPath\Keyvault\Remove-Network-Whitelist-from-Keyvault.ps1" -KeyvaultName $CertificateKeyvaultName -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName
    }

    Write-Host "Cert is in place!"

    # ======= Create entry point =======

    # Create Backend Pool for your site (if no BackendDomainName was given, the pool will be empty)
    Write-Host "Creating backend pool"
    $optionalParameters = @()
    if (![string]::IsNullOrWhiteSpace($BackendDomainName))
    {
        $optionalParameters += '--servers', $BackendDomainName
    }
    Invoke-Executable az network application-gateway address-pool create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpspool" --resource-group $ApplicationGatewayResourceGroupName @optionalParameters | Out-Null
    Write-Host "Created backend pool"

    # Create Health Probe
    Write-Host "Creating healthprobe"
    if ([string]::IsNullOrWhiteSpace($HealthProbeDomainName))
    {
        Invoke-Executable az network application-gateway probe create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpsprobe" --path $HealthProbeUrlPath --protocol $HealthProbeProtocol --host-name-from-http-settings true --match-status-codes $HealthProbeMatchStatusCodes --interval $HealthProbeIntervalInSeconds --timeout $HealthProbeTimeoutInSeconds --threshold $HealthProbeNumberOfTriesBeforeMarkedDown --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    }
    else
    {
        Invoke-Executable az network application-gateway probe create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpsprobe" --path $HealthProbeUrlPath --protocol $HealthProbeProtocol --host-name-from-http-settings false --host $HealthProbeDomainName --match-status-codes $HealthProbeMatchStatusCodes --interval $HealthProbeIntervalInSeconds --timeout $HealthProbeTimeoutInSeconds --threshold $HealthProbeNumberOfTriesBeforeMarkedDown --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    }
    Write-Host "Created healthprobe"

    # Create HTTP settings
    Write-Host "Creating HTTP settings"
    $optionalParameters = @(
        '--host-name-from-backend-pool', (!$IngressDomainName.StartsWith("*"))
    )
    if (Test-Path -Path ($HttpsSettingsCustomRootCertificateFilePath ?? '') )
    {
        $certificateName = Split-Path $HttpsSettingsCustomRootCertificateFilePath -LeafBase
        Invoke-Executable az network application-gateway root-cert create --cert-file $HttpsSettingsCustomRootCertificateFilePath --gateway-name $ApplicationGatewayName --name $certificateName --resource-group $ApplicationGatewayResourceGroupName

        $optionalParameters += '--root-certs', $certificateName
    }
    Invoke-Executable az network application-gateway http-settings create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpssettings" --protocol $HttpsSettingsRequestToBackendProtocol --port $HttpsSettingsRequestToBackendPort --cookie-based-affinity $HttpsSettingsRequestToBackendCookieAffinity --affinity-cookie-name "$dashedDomainName-httpscookie" --connection-draining-timeout $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds --timeout $HttpsSettingsRequestToBackendTimeoutInSeconds --enable-probe $true --probe "$dashedDomainName-httpsprobe" --resource-group $ApplicationGatewayResourceGroupName @optionalParameters | Out-Null
    Write-Host "Created HTTP settings"

    # Get the id of the SSL certificate available for the Applicaton Gateway to use in the next step for creating the listener
    Write-Host "Get SSL Certificate ID from AppGateway"
    $sslCertId = (Invoke-Executable az network application-gateway ssl-cert show --gateway-name $ApplicationGatewayName --ids $appgatewayCertificate --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
    Write-Host "AppGateway SSL Cert ID: $sslCertId"

    # Create Listener
    Write-Host "Creating HTTPS Listener"
    Invoke-Executable az network application-gateway http-listener create --frontend-port $portName --frontend-ip $frontendIpName --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpslistener" --host-names $IngressDomainName --ssl-cert $sslCertId --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    Write-Host "Created HTTPS Listener"

    # Check if the ruletype is PathBasedRouting
    if ($ApplicationGatewayRuleType -eq 'PathBasedRouting')
    {
        Write-Host "Creating/updating url map for PathBasedRouting for $applicationGatewayRuleDefaultIngressDomainNameDashed"
        Invoke-Executable az network application-gateway url-path-map create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-url-map" --paths $ApplicationGatewayRulePath --resource-group $ApplicationGatewayResourceGroupName --default-address-pool "$applicationGatewayRuleDefaultIngressDomainNameDashed-httpspool" --default-http-settings "$applicationGatewayRuleDefaultIngressDomainNameDashed-httpssettings" --address-pool "$dashedDomainName-httpspool" --http-settings "$dashedDomainName-httpssettings" --rule-name "$dashedDomainName-rule"
        
        $urlPathMapId = (Invoke-Executable az network application-gateway url-path-map show --gateway-name $ApplicationGatewayName --name "$dashedDomainName-url-map" --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
        New-ApplicationGatewayRule -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -DashedDomainName $applicationGatewayRuleDefaultIngressDomainNameDashed -ApplicationGatewayRuleType "PathBasedRouting" -ApplicationGatewayRuleUrlPathMapId $urlPathMapId
    }
    else
    {
        New-ApplicationGatewayRule -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -DashedDomainName $dashedDomainName -ApplicationGatewayRuleType "Basic"
    }

    # ======= End Create entry point =======

    # ======= Create HTTP to HTTPS redirection entry point if not wildcard domain =======
    if (!$IngressDomainName.StartsWith("*"))
    {
        # Fetch port 80 (which should be redirected)
        Write-Host "Fetching port 80 portname"
        $portName = Get-ApplicationGatewayPortName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -PortNumber 80
        Write-Host "Portname for port 80: $portName"

        # Create the lister entrypoint for HTTP (for redirecting to HTTPS)
        Write-Host "Creating HTTP Listener"
        Invoke-Executable az network application-gateway http-listener create --name "$dashedDomainName-httplistener" --frontend-ip $frontendIpName --frontend-port $portName --host-names $IngressDomainName --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName | Out-Null
        Write-Host "Created HTTP Listener"

        # Create redirect config for HTTP to HTTPS
        Write-Host "Creating redirect config (HTTP to HTTPS)"
        Invoke-Executable az network application-gateway redirect-config create --name "$dashedDomainName-httpredirector" --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --type Permanent --target-listener "$($dashedDomainName)-httpslistener" --include-path true --include-query-string true | Out-Null
        Write-Host "Created redirect config (HTTP to HTTPS)"

        # Create routing rule for HTTP to HTTPS
        $gatewayRule = Invoke-Executable -AllowToFail az network application-gateway rule show --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httprule" | ConvertFrom-Json
        if (!$gatewayRule)
        {
            $optionalParameters = @()
            Write-Host "Creating routing rule for HTTP entrypoint"

            $lastPriority = [nullable[int]](Invoke-Executable az network application-gateway rule list --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --query "[? priority!=null]|max_by([].{Priority:priority}, &Priority) | Priority")
            if($lastPriority -ne $null){
                $priority = $lastPriority + 10
                $optionalParameters += "--priority", $priority
            }
            Invoke-Executable az network application-gateway rule create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httprule" --resource-group $ApplicationGatewayResourceGroupName --http-listener "$($dashedDomainName)-httplistener" --rule-type Basic --redirect-config "$($dashedDomainName)-httpredirector" @optionalParameters| Out-Null
            Write-Host "Created routing rule for HTTP entrypoint"
        }
        else
        {
            Write-Host "Updating routing rule for HTTP entrypoint"
            Invoke-Executable az network application-gateway rule update --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httprule" --resource-group $ApplicationGatewayResourceGroupName --http-listener "$($dashedDomainName)-httplistener" --rule-type Basic --redirect-config "$($dashedDomainName)-httpredirector" | Out-Null
            Write-Host "Updated routing rule for HTTP entrypoint"
        }
    }
    else
    {
        Write-Host "Redirect not created because the domain is a wildcard domain."
    }
    # ======= End Create HTTP to HTTPS redirection entry point =======

    # ======= Check if our backend is healthy (if BackendDomainName was given) =======
    if (![string]::IsNullOrWhiteSpace($BackendDomainName))
    {
        Write-Host "Checking if backend is healthy..."
        $backendStatus = Test-ApplicationGatewayBackendIsHealthy -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -BackendDomainName $BackendDomainName
        if ($backendStatus.BackendIsHealthy)
        {
            Write-Host "$BackendDomainName online!"
        }
        else
        {
            Write-Footer -ScopedPSCmdlet $PSCmdlet
            throw "Backend $BackendDomainName seems to be unhealthy! Please verify your backend & healthprobe settings. Healthprobelog: $($backendStatus.HealthProbeLog)"
        }
    }
    # ======= End Check if our backend is healthy =======

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}
#endregion Main function

