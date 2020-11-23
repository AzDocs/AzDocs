#region Helper functions

<#
.SYNOPSIS
    Fetch Frontend IP Name for App Gateway
.DESCRIPTION
    Fetch Frontend IP Name for App Gateway
#>
function Get-FrontendIpName
{
    [OutputType([string])]
    param (
        [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
        [Parameter(Mandatory)][string] $gatewayName,
        [Parameter(Mandatory)][string] $interfaceType
    )
    $appgateway_frontendips = Invoke-Executable az network application-gateway frontend-ip list --gateway-name $gatewayName --resource-group $sharedServicesResourceGroupName | ConvertFrom-Json
    $ip = $appgateway_frontendips | Where-Object { ![String]::IsNullOrWhiteSpace($_."$($interfaceType)IpAddress") }
    return $ip.name
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
        [Parameter(Mandatory)][byte[]] $certBytes
    )
    $p7b = [System.Security.Cryptography.Pkcs.SignedCms]::new()
    $p7b.Decode($certBytes)
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
    [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
    [Parameter(Mandatory)][string] $gatewayName,
    [Parameter()][string] $domainName
)
{
    $certlist = Invoke-Executable az network application-gateway ssl-cert list --resource-group $sharedServicesResourceGroupName --gateway-name $gatewayName | ConvertFrom-Json
    foreach ($cert in $certlist)
    {
        $subject = ""
        if ($cert.publicCertData)
        {
            $certBytes = [Convert]::FromBase64String($cert.publicCertData)
            $x509 = ConvertTo-Certificate $certBytes
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
        if ($domainName -match $regexcn)
        {
            return $cert.id
        }
    }
}

<#
.SYNOPSIS
Creates a port on an appgateway
.DESCRIPTION
Creates a port on an appgateway
#>
function New-Port (
    [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
    [Parameter(Mandatory)][string] $gatewayName,
    [Parameter(Mandatory)][string] $portNumber
)
{
    return Invoke-Executable az network application-gateway frontend-port create --resource-group $sharedServicesResourceGroupName --gateway-name $gatewayName --name "port_$portNumber" --port $portNumber | ConvertFrom-Json
}

<#
.SYNOPSIS
Fetches the portname based on the given portnumber from an given AppGateway
.DESCRIPTION
Fetches the portname based on the given portnumber from an given AppGateway
#>
function Get-PortName (
    [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
    [Parameter(Mandatory)][string] $gatewayName,
    [Parameter(Mandatory)][int] $portNumber )
{
    $ports = Invoke-Executable az network application-gateway frontend-port list --gateway-name $gatewayName --resource-group $sharedServicesResourceGroupName | ConvertFrom-Json
    $port = $ports | Where-Object { $_.port -eq $portNumber }

    # Create port if it does not exist
    if (!$port)
    {
        $result = New-Port -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -portNumber $portNumber
        $port = $result.frontendPorts | Where-Object { $_.port -eq $portNumber }
    }

    if (![String]::IsNullOrWhiteSpace($port))
    {
        return $port.name
    }
    else
    {
        Write-Error "Port could not be found"
    }
}

<#
.SYNOPSIS
    Fetches the certificate from Keyvault
.DESCRIPTION
    Fetches the certificate from Keyvault
#>
function Get-CertificateFromKeyvault (
    [Parameter(Mandatory)][string] $sharedServicesKeyvaultName,
    [Parameter(Mandatory)][string] $domainName,
    [Parameter(Mandatory)][string] $sourceCertificateThumbprint )
{
    if ($sourceCertificateThumbprint)
    {
        $certificates = Invoke-Executable az keyvault certificate list --vault-name $sharedServicesKeyvaultName --query="[?x509ThumbprintHex=='$sourceCertificateThumbprint']" | ConvertFrom-Json
        if ($certificates -and $certificates.Length -eq 1)
        {
            return $certificates[0]
        }
        elseif ($certificates -and $certificates.Length -gt 1)
        {
            Write-Error "Multiple certs with the same thumbprint found."
            throw
        }
    }

    $certlist = Invoke-Executable az keyvault certificate list --vault-name $sharedServicesKeyvaultName --include-pending false | ConvertFrom-Json

    if (!$certlist)
    {
        return $null
    }

    foreach ($cert in $certlist)
    {
        $subject = (Invoke-Executable az keyvault certificate show --id $cert.id | ConvertFrom-Json).policy.x509CertificateProperties.subject

        $cn = $subject -replace '(CN=)(.*?),.*', '$2'
        $regexcn = '^' + $cn.replace('.', '\.').Replace('*', '[A-Za-z0-9\-]+') + '$'
        if ($domainName -match $regexcn)
        {
            return $cert
        }
    }

    return $null
}

# Grants the current user permissions on keyvault to work with the contents
function Grant-MePermissionsOnKeyvault (
    [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
    [Parameter(Mandatory)][string] $sharedServicesKeyvaultName )
{
    $identityId = (Invoke-Executable az account show | ConvertFrom-Json).user.name
    Invoke-Executable az keyvault set-policy --name $sharedServicesKeyvaultName --certificate-permissions get list create update import purge --key-permissions get list create update import purge --secret-permissions get list set purge --storage-permissions get list update set purge --spn $identityId --resource-group $sharedServicesResourceGroupName | Out-Null
}

# Adds a certificate to Keyvault
function Add-CertificateToKeyvault (
    [Parameter(Mandatory)][string] $sharedServicesKeyvaultName,
    [Parameter(Mandatory)][string] $certificateName,
    [Parameter(Mandatory)][string] $certificatePath,
    [Parameter(Mandatory)][string] $certificatePassword,
    [Parameter(Mandatory)][string] $commonName )
{
    Invoke-Executable az keyvault certificate import --vault-name $sharedServicesKeyvaultName --name $certificateName --file $certificatePath --password $certificatePassword --tags CommonName=$commonName
}

# Adds a certificate from Keyvault to the AppGateway
function Add-KeyvaultCertificateToApplicationGateway
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
        [Parameter(Mandatory)][string] $sharedServicesKeyvaultName,
        [Parameter(Mandatory)][string] $gatewayName,
        [Parameter(Mandatory)][string] $certificateName
    )
    # Get the keyvault-secret-id of the certificate in the Keyvault
    $keyvaultSecretId = Invoke-Executable az keyvault secret show --name $certificateName --vault-name $sharedServicesKeyvaultName --query=id
    # Upload an SSL certificate using key-vault-secret-id of a KeyVault Secret
    Invoke-Executable az network application-gateway ssl-cert create --gateway-name $gatewayName --name $certificateName --key-vault-secret-id $keyvaultSecretId --resource-group $sharedServicesResourceGroupName
}


# Fetches the common name for a certificate (pfx)
function Get-CommonnameFromCertificate
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $certificatePath,
        [Parameter(Mandatory)][string] $certificatePassword
    )


    $certificate = Get-Certificate $certificatePath $certificatePassword
    $subject = $certificate.Subject
    Write-Host "Certificate subject: $subject"
    $cn = $subject -replace "(CN=)(.*?),.*", '$2'
    $cn = $cn -replace "CN=", ""
    return $cn
}

function Get-Certificate
{
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param (
        [Parameter(Mandatory)][string] $certificatePath,
        [Parameter(Mandatory)][string] $certificatePassword
    )
    return [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificatePath, $certificatePassword);
}

function Test-ShouldReplaceCertificate(
    [Parameter(Mandatory)][string] $certificatePath,
    [Parameter(Mandatory)][string] $certificatePassword,
    [Parameter()][PSObject] $keyvaultCertificate
)
{

    if (!$keyvaultCertificate)
    {
        return $false
    }

    if (![String]::IsNullOrWhiteSpace($certificatePath) -and (Test-Path $certificatePath))
    {
        Write-Host "Let's see if we need to upload the source certificate (because it is newer)."
        $sourceCertificate = Get-Certificate -certificatePath $certificatePath -certificatePassword $certificatePassword
        return $sourceCertificate.Thumbprint -ne $keyvaultCertificate.x509ThumbprintHex -and $sourceCertificate.NotAfter -gt $keyvaultCertificate.attributes.expires -and (Get-Date) -gt $sourceCertificate.notBefore
    }
    #TODO wat moet die returnen als het bovenstaande niet waar is?
}

# Fetches the dashed domainname for a given domainname. It also replaces * with "wildcard" (excluding the quotes)
function Get-DashedDomainname
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $domainName
    )
    return $domainName.Replace("-", "--").Replace(".", "-").Replace("*", "wildcard")
}

# Check if the domain (backend) is healthy
function Test-AppGwBackendIsHealthy
{
    [OutputType([boolean])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
        [Parameter(Mandatory)][string] $gatewayName,
        [Parameter(Mandatory)][string] $domainName
    )

    # Fetch Backends from Azure
    $backends = (Invoke-Executable az network application-gateway show-backend-health --name $gatewayName --resource-group $sharedServicesResourceGroupName --query backendAddressPools[].backendHttpSettingsCollection[].servers[] | ConvertFrom-Json)

    # Select the backend we search
    $backend = $backends | Where-Object -Property address -EQ $domainName

    # Check if the backend is present
    if (!$backend)
    {
        # Backend is not present
        throw "Could not find specified backend"
    }

    # Check if backend is healthy
    return $backend.health -eq "Healthy"
}

# Fetches the User Identity which is used by the AppGateway
function Get-UserIdentityForGateway
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$sharedServicesResourceGroupName,
        [Parameter(Mandatory)][string]$gatewayName
    )
    #TODO check if not Invoke-Executable is needed
    return (Invoke-Executable az identity show --name "useridentity-$gatewayName" --resource-group $sharedServicesResourceGroupName -AllowToFail)
}

# Make sure our AppGateway User Identity is assigned to keyvault (the process will break if this isn't the case)
function Grant-AppGwToKeyvault
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
        [Parameter(Mandatory)][string] $gatewayName,
        [Parameter(Mandatory)][string] $sharedServicesKeyvaultName
    )
    $userIdentity = Invoke-Executable az network application-gateway identity show --gateway-name $gatewayName --resource-group $sharedServicesResourceGroupName -AllowToFail | ConvertFrom-Json
    $principalId = $userIdentity.userAssignedIdentities.psobject.Properties.value.principalId
    $userIdentityAssigned = $userIdentity.userAssignedIdentities.psobject.Properties.Name -contains "useridentity-$gatewayName"
    Write-Host "AppGW Identity before assigning: $principalId"
    if (!$principalId -or !$userIdentityAssigned)
    {
        $userIdentity = Get-UserIdentityForGateway -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName | ConvertFrom-Json
        if (!$userIdentity)
        {
            #create user assigned identity
            $userIdentity = Invoke-Executable az identity create --name "useridentity-$gatewayName" --resource-group $sharedServicesResourceGroupName | ConvertFrom-Json
        }
        $principalId = $userIdentity.principalId
        $userIdentityId = $userIdentity.id

        # Assign User Identity to Application Gateway
        Write-Host "Assigning User Identity to App Gateway with User ID: $userIdentityId"
        Invoke-Executable az network application-gateway identity assign --resource-group $sharedServicesResourceGroupName --gateway-name $gatewayName --identity $userIdentityId | Out-Null
    }
    Write-Host "UserIdentity Principal ID: $principalId"
    Invoke-Executable az keyvault set-policy --name $sharedServicesKeyvaultName --object-id $principalId --certificate-permissions backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers purge recover restore setissuers update --key-permissions backup create decrypt delete encrypt get import list purge recover restore sign unwrapKey update verify wrapKey --secret-permissions backup delete get list purge recover restore set --storage-permissions backup delete deletesas get getsas list listsas purge recover regeneratekey restore set setsas update | Out-Null
}

#endregion


#region Main function
function New-Entrypoint
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String] $certificatePath,
        [Parameter(Mandatory)][string] $domainName,
        [Parameter(Mandatory)][string] $gatewayName,
        [Parameter(Mandatory)][string] $gatewayType,
        [Parameter(Mandatory)][string] $sharedServicesResourceGroupName,
        [Parameter(Mandatory)][string] $sharedServicesKeyvaultName,
        [Parameter(Mandatory)][string] $certificatePassword,
        [Parameter(Mandatory)][string] $backendDomainname,
        [Parameter(Mandatory)][string] $healthProbePath,
        [Parameter()][int] $healthProbeInterval = 60,
        [Parameter()][int] $healthProbeThreshold = 2,
        [Parameter()][int] $healthProbeTimeout = 20,
        [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $healthProbeProtocol = "HTTPS",
        [Parameter()][ValidateSet("HTTP", "HTTPS")][string] $httpsSettingsProtocol = "HTTPS",
        [Parameter()][ValidateRange(0, 65535)][int] $httpsSettingsPort = 443,
        [Parameter()][ValidateSet("Disabled", "Enabled")][string] $httpsSettingsCookieAffinity = "Disabled",
        [Parameter()][int] $httpsSettingsConnectionDrainingTimeout = 0,
        [Parameter()][int] $httpsSettingsTimeout = 30,
        [Parameter()][string] $matchStatusCodes = "200-399",
        [Parameter(Mandatory)][ValidateSet("Basic", "PathBasedRouting")][string] $gatewayRuleType
    )

    # Fetch the commonname for the given certificate
    Write-Host "Fetching commonname"
    $commonName = Get-CommonnameFromCertificate -certificatePath $certificatePath -certificatePassword $certificatePassword
    Write-Host "Commonname: $commonName"

    # Get the dashed version of the common name to use as the certname
    Write-Host "Fetching certificatename"
    $certificateName = Get-DashedDomainname -domainName $commonName
    Write-Host "Certificatename: $certificateName"

    # Get the dashed version of the domainname to use as name for multiple app gateway components
    Write-Host "Fetching dashed domainname"
    $dashedDomainName = Get-DashedDomainname -domainName $domainName
    Write-Host "Dashed domainname: $dashedDomainName"

    # Fetch the name of the Frontend IP based on the interface type (public or private)
    Write-Host "Fetching Frontend IPname"
    $frontendIpName = Get-FrontendIpName -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -interfaceType $gatewayType
    Write-Host "Frontend IPname: $frontendIpName"

    # Fetch the portname based on the portnumber
    Write-Host "Fetching portname for HTTPS"
    $portName = Get-PortName -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -portNumber 443
    Write-Host "Portname: $portName"

    Write-Host "Granting permissions on keyvault for executing user"
    # Grant the current logged in user (service principal) rights to modify certificates in the keyvault (for uploading & fetching the certificate)
    Grant-MePermissionsOnKeyvault -sharedServicesResourceGroupName $sharedServicesResourceGroupName -sharedServicesKeyvaultName $sharedServicesKeyvaultName
    Write-Host "Granted permissions on keyvault for executing user"

    Write-Host "Assigning Application Gateway identity to Keyvault"
    # Make sure our AppGateway User Identity is assigned to keyvault (the process will break if this isn't the case)
    Grant-AppGwToKeyvault -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -sharedServicesKeyvaultName $sharedServicesKeyvaultName
    Write-Host "Application Gateway identity assigned to Keyvault"

    # Fetch the certificate from the AppGateway if it exists
    Write-Host "Fetching AppGateway certificate"
    $appgatewayCertificate = Get-CertificateFromApplicationGateway -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -domainName $domainName
    Write-Host "AppGateway Certificate: $appgatewayCertificate"

    # Fetch the certificate from Keyvault if it exists
    Write-Host "Fetching Keyvault certificate"
    $sourceCertificate = Get-Certificate -certificatePath $certificatePath -certificatePassword $certificatePassword
    $keyvaultCertificate = Get-CertificateFromKeyvault -sharedServicesKeyvaultName $sharedServicesKeyvaultName -domainName $domainName -sourceCertificateThumbprint $sourceCertificate.Thumbprint
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
    $shouldReplaceCertificateWithSourceCertificate = Test-ShouldReplaceCertificate -certificatePath $certificatePath -certificatePassword $certificatePassword -keyvaultCertificate $keyvaultCertificate
    if ($shouldReplaceCertificateWithSourceCertificate)
    {
        Write-Host "We should replace the certificate on the AppGw & Keyvault because the source certificate is renewed."
    }

    Write-Host "Checking if/where certificates exists and if we should replace it..."
    # Check if the certificate exists in the gateway
    if ([String]::IsNullOrWhiteSpace($appgatewayCertificate) -or $shouldReplaceCertificateWithSourceCertificate)
    {
        Write-Host "AppGateway cert not found or should be replaced."
        # Check if the certificate exists in the keyvault
        if (!$keyvaultCertificate -or [String]::IsNullOrWhiteSpace($keyvaultCertificate.id) -or $shouldReplaceCertificateWithSourceCertificate)
        {
            Write-Host "KeyVault cert not found or should be replaced."
            # Check if the certificate exists on disk (if not, stop the process)
            if ([String]::IsNullOrWhiteSpace($certificatePath) -or !(Test-Path $certificatePath))
            {
                Write-Error "There is no source certificate found (Azure DevOps)."
            }
            # Add the certificate to keyvault if its not there yet
            $keyvaultCertificate = Add-CertificateToKeyvault -sharedServicesKeyvaultName $sharedServicesKeyvaultName -certificateName $certificateName -certificatePath $certificatePath -certificatePassword $certificatePassword -commonName $commonName
            Write-Host "Cert added/replaced to keyvault"
        }
        # Add the certificate to the AppGateway if its not there yet
        $appgatewayCertificate = Add-KeyvaultCertificateToApplicationGateway -sharedServicesResourceGroupName $sharedServicesResourceGroupName -sharedServicesKeyvaultName $sharedServicesKeyvaultName -gatewayName $gatewayName -certificateName $certificateName
        Write-Host "Cert added/replaced to appgateway"
    }
    Write-Host "Cert is in place!"


    # ======= Create entry point =======

    # Create Backend Pool for your site
    Write-Host "Creating backend pool"
    Invoke-Executable az network application-gateway address-pool create --gateway-name $gatewayName --name "$dashedDomainName-httpspool" --servers $backendDomainname --resource-group $sharedServicesResourceGroupName | Out-Null
    Write-Host "Created backend pool"

    # Create Health Probe
    Write-Host "Creating healthprobe"
    Invoke-Executable az network application-gateway probe create --gateway-name $gatewayName --name "$dashedDomainName-httpsprobe" --path $healthProbePath --protocol $healthProbeProtocol --host-name-from-http-settings true --match-status-codes $matchStatusCodes --interval $healthProbeInterval --timeout $healthProbeTimeout --threshold $healthProbeThreshold --resource-group $sharedServicesResourceGroupName | Out-Null
    Write-Host "Created healthprobe"

    # Create HTTP settings
    Write-Host "Creating HTTP settings"
    Invoke-Executable az network application-gateway http-settings create --gateway-name $gatewayName --name "$dashedDomainName-httpssettings" --protocol $httpsSettingsProtocol --port $httpsSettingsPort --cookie-based-affinity $httpsSettingsCookieAffinity --affinity-cookie-name "$dashedDomainName-httpscookie" --connection-draining-timeout $httpsSettingsConnectionDrainingTimeout --timeout $httpsSettingsTimeout --enable-probe $true --probe "$dashedDomainName-httpsprobe" --host-name-from-backend-pool $true --resource-group $sharedServicesResourceGroupName | Out-Null
    Write-Host "Created HTTP settings"

    # Get the id of the SSL certificate available for the Applicaton Gateway to use in the next step for creating the listener
    Write-Host "Get SSL Certificate ID from AppGateway"
    $sslCertId = (Invoke-Executable az network application-gateway ssl-cert show --gateway-name $gatewayName --name $certificateName --resource-group $sharedServicesResourceGroupName | ConvertFrom-Json).id
    Write-Host "AppGateway SSL Cert ID: $sslCertId"

    # Create Listener
    Write-Host "Creating HTTPS Listener"
    Invoke-Executable az network application-gateway http-listener create --frontend-port $portName --frontend-ip $frontendIpName --gateway-name $gatewayName --name "$dashedDomainName-httpslistener" --host-name $domainName --ssl-cert $sslCertId --resource-group $sharedServicesResourceGroupName | Out-Null
    Write-Host "Created HTTPS Listener"

    # Add the routing rule
    Write-Host "Creating routing rule"
    Invoke-Executable az network application-gateway rule create --gateway-name $gatewayName --name "$dashedDomainName-httpsrule" --http-listener "$dashedDomainName-httpslistener" --address-pool "$dashedDomainName-httpspool" --http-settings "$dashedDomainName-httpssettings" --rule-type $gatewayRuleType --resource-group $sharedServicesResourceGroupName | Out-Null
    Write-Host "Created routing rule"

    # ======= End Create entry point =======



    # ======= Create HTTP to HTTPS redirection entry point =======

    # Fetch port 80 (which should be redirected)
    Write-Host "Fetching port 80 portname"
    $portName = Get-PortName -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -portNumber 80
    Write-Host "Portname for port 80: $portName"

    # Create the lister entrypoint for HTTP (for redirecting to HTTPS)
    Write-Host "Creating HTTP Listener"
    Invoke-Executable az network application-gateway http-listener create --name "$dashedDomainName-httplistener" --frontend-ip $frontendIpName --frontend-port $portName --host-name $domainName --resource-group $sharedServicesResourceGroupName --gateway-name $gatewayName | Out-Null
    Write-Host "Created HTTP Listener"

    # Create redirect config for HTTP to HTTPS
    Write-Host "Creating redirect config (HTTP to HTTPS)"
    Invoke-Executable az network application-gateway redirect-config create --name "$dashedDomainName-httpredirector" --gateway-name $gatewayName --resource-group $sharedServicesResourceGroupName --type Permanent --target-listener "$($dashedDomainName)-httpslistener" --include-path true --include-query-string true | Out-Null
    Write-Host "Created redirect config (HTTP to HTTPS)"

    # Create routing rule for HTTP to HTTPS
    Write-Host "Creating routing rule for HTTP entrypoint"
    Invoke-Executable az network application-gateway rule create --gateway-name $gatewayName --name "$dashedDomainName-httprule" --resource-group $sharedServicesResourceGroupName --http-listener "$($dashedDomainName)-httplistener" --rule-type Basic --redirect-config "$($dashedDomainName)-httpredirector" | Out-Null
    Write-Host "Created routing rule for HTTP entrypoint"

    # ======= End Create HTTP to HTTPS redirection entry point =======

    # ======= Check if our backend is healthy =======
    Write-Host "Checking if backend is healthy..."
    if (Test-AppGwBackendIsHealthy -sharedServicesResourceGroupName $sharedServicesResourceGroupName -gatewayName $gatewayName -domainName $backendDomainname)
    {
        Write-Host "$backendDomainname online!"
    }
    else
    {
        throw "$backendDomainname offline!"
    }
    # ======= End Check if our backend is healthy =======
}
#endregion Main function