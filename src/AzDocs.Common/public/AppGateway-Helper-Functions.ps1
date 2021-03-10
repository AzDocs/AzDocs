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

    Write-Host "Geen certificaat gevonden die aan de eisen voldoet."

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

    Write-Output Invoke-Executable az network application-gateway frontend-port create --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name "port_$PortNumber" --port $PortNumber | ConvertFrom-Json

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
    [Parameter(Mandatory)][string] $KeyvaultName )
{
    Write-Header -ScopedPSCmdlet $PSCmdlet

    $identityId = (Invoke-Executable az account show | ConvertFrom-Json).user.name
    Invoke-Executable az keyvault set-policy --name $KeyvaultName --certificate-permissions get list create update import purge --key-permissions get list create update import purge --secret-permissions get list set purge --storage-permissions get list update set purge --spn $identityId --resource-group $KeyvaultResourceGroupName | Out-Null

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
    #TODO wat moet die returnen als het bovenstaande niet waar is?
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
    Write-Output $backendHealthy

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

    if ($null -eq $currentRule.HeaderName -or $null -eq $currentRule.HeaderValue -or $null -eq $currentRule.ConditionVariable -or $null -eq $currentRule.ConditionPattern -or $null -eq $currentRule.ConditionNegate) {
        if ($null -eq $newRule.HeaderName -or $null -eq $newRule.HeaderValue -or $null -eq $newRule.ConditionVariable -or $null -eq $newRule.ConditionPattern -or $null -eq $newRule.ConditionNegate) {
            throw 'Missing one of the propertynames to check on: HeaderName, HeaderValue, ConditionVariable, ConditionPattern and ConditionNegate'
        }
    }

    if ($currentRule.HeaderName -ne $newRule.HeaderName -or $currentRule.HeaderValue -ne $newRule.HeaderValue -or $currentRule.ConditionVariable -ne $newRule.ConditionVariable -or $currentRule.ConditionPattern -ne $newRule.ConditionPattern -or $currentRule.ConditionNegate -ne $newRule.ConditionNegate) {
        Write-Host "Values have changed for the rule. Updating."
        Write-Output $true
    }
    else {
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
        [Parameter(Mandatory)][String] $HeaderValue,
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
        [Parameter(Mandatory)][string] $BackendDomainName,
        [Parameter(Mandatory)][string] $HealthProbeUrlPath,
        [Parameter()][int] $HealthProbeIntervalInSeconds = 60,
        [Parameter()][int] $HealthProbeNumberOfTriesBeforeMarkedDown = 2,
        [Parameter()][int] $HealthProbeTimeoutInSeconds = 20,
        [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $HealthProbeProtocol = "HTTPS",
        [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $HttpsSettingsRequestToBackendProtocol = "HTTPS",
        [Parameter()][ValidateRange(0, 65535)][int] $HttpsSettingsRequestToBackendPort = 443,
        [Parameter()][ValidateSet("Disabled", "Enabled")][string] $HttpsSettingsRequestToBackendCookieAffinity = "Disabled",
        [Parameter()][int] $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds = 0,
        [Parameter()][int] $HttpsSettingsRequestToBackendTimeoutInSeconds = 30,
        [Parameter()][string] $HealthProbeMatchStatusCodes = "200-399",
        [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $ApplicationGatewayRuleType
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

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
        # Add the certificate to the AppGateway if its not there yet
        $appgatewayCertificate = Add-KeyvaultCertificateToApplicationGateway -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -KeyvaultName $CertificateKeyvaultName -ApplicationGatewayName $ApplicationGatewayName -KeyvaultCertificateName $CertificateName
        Write-Host "Cert added/replaced to appgateway"
    }
    Write-Host "Cert is in place!"


    # ======= Create entry point =======

    # Create Backend Pool for your site
    Write-Host "Creating backend pool"
    Invoke-Executable az network application-gateway address-pool create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpspool" --servers $BackendDomainName --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    Write-Host "Created backend pool"

    # Create Health Probe
    Write-Host "Creating healthprobe"
    Invoke-Executable az network application-gateway probe create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpsprobe" --path $HealthProbeUrlPath --protocol $HealthProbeProtocol --host-name-from-http-settings true --match-status-codes $HealthProbeMatchStatusCodes --interval $HealthProbeIntervalInSeconds --timeout $HealthProbeTimeoutInSeconds --threshold $HealthProbeNumberOfTriesBeforeMarkedDown --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    Write-Host "Created healthprobe"

    # Create HTTP settings
    Write-Host "Creating HTTP settings"
    Invoke-Executable az network application-gateway http-settings create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpssettings" --protocol $HttpsSettingsRequestToBackendProtocol --port $HttpsSettingsRequestToBackendPort --cookie-based-affinity $HttpsSettingsRequestToBackendCookieAffinity --affinity-cookie-name "$dashedDomainName-httpscookie" --connection-draining-timeout $HttpsSettingsRequestToBackendConnectionDrainingTimeoutInSeconds --timeout $HttpsSettingsRequestToBackendTimeoutInSeconds --enable-probe $true --probe "$dashedDomainName-httpsprobe" --host-name-from-backend-pool $true --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    Write-Host "Created HTTP settings"

    # Get the id of the SSL certificate available for the Applicaton Gateway to use in the next step for creating the listener
    Write-Host "Get SSL Certificate ID from AppGateway"
    $sslCertId = (Invoke-Executable az network application-gateway ssl-cert show --gateway-name $ApplicationGatewayName --name $CertificateName --resource-group $ApplicationGatewayResourceGroupName | ConvertFrom-Json).id
    Write-Host "AppGateway SSL Cert ID: $sslCertId"

    # Create Listener
    Write-Host "Creating HTTPS Listener"
    Invoke-Executable az network application-gateway http-listener create --frontend-port $portName --frontend-ip $frontendIpName --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpslistener" --host-name $IngressDomainName --ssl-cert $sslCertId --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    Write-Host "Created HTTPS Listener"

    # Add the routing rule
    Write-Host "Creating routing rule"
    Invoke-Executable az network application-gateway rule create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httpsrule" --http-listener "$dashedDomainName-httpslistener" --address-pool "$dashedDomainName-httpspool" --http-settings "$dashedDomainName-httpssettings" --rule-type $ApplicationGatewayRuleType --resource-group $ApplicationGatewayResourceGroupName | Out-Null
    Write-Host "Created routing rule"

    # ======= End Create entry point =======



    # ======= Create HTTP to HTTPS redirection entry point =======

    # Fetch port 80 (which should be redirected)
    Write-Host "Fetching port 80 portname"
    $portName = Get-ApplicationGatewayPortName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -PortNumber 80
    Write-Host "Portname for port 80: $portName"

    # Create the lister entrypoint for HTTP (for redirecting to HTTPS)
    Write-Host "Creating HTTP Listener"
    Invoke-Executable az network application-gateway http-listener create --name "$dashedDomainName-httplistener" --frontend-ip $frontendIpName --frontend-port $portName --host-name $IngressDomainName --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName | Out-Null
    Write-Host "Created HTTP Listener"

    # Create redirect config for HTTP to HTTPS
    Write-Host "Creating redirect config (HTTP to HTTPS)"
    Invoke-Executable az network application-gateway redirect-config create --name "$dashedDomainName-httpredirector" --gateway-name $ApplicationGatewayName --resource-group $ApplicationGatewayResourceGroupName --type Permanent --target-listener "$($dashedDomainName)-httpslistener" --include-path true --include-query-string true | Out-Null
    Write-Host "Created redirect config (HTTP to HTTPS)"

    # Create routing rule for HTTP to HTTPS
    Write-Host "Creating routing rule for HTTP entrypoint"
    Invoke-Executable az network application-gateway rule create --gateway-name $ApplicationGatewayName --name "$dashedDomainName-httprule" --resource-group $ApplicationGatewayResourceGroupName --http-listener "$($dashedDomainName)-httplistener" --rule-type Basic --redirect-config "$($dashedDomainName)-httpredirector" | Out-Null
    Write-Host "Created routing rule for HTTP entrypoint"

    # ======= End Create HTTP to HTTPS redirection entry point =======

    # ======= Check if our backend is healthy =======
    Write-Host "Checking if backend is healthy..."
    if (Test-ApplicationGatewayBackendIsHealthy -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -BackendDomainName $BackendDomainName)
    {
        Write-Host "$BackendDomainName online!"
    }
    else
    {
        Write-Footer -ScopedPSCmdlet $PSCmdlet
        throw "$BackendDomainName offline!"
    }
    # ======= End Check if our backend is healthy =======

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}
#endregion Main function

