function Get-CommonNameAndCertificateName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CertificatePath,
        [Parameter(Mandatory)][string] $CertificatePassword
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    Write-Host "Fetching commonname"
    $CommonName = Get-CommonnameFromCertificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword
    Write-Host "Commonname: $CommonName"

    # Get the dashed version of the common name to use as the certname
    Write-Host "Fetching certificatename"
    $CertificateName = Get-DashedDomainname -DomainName $CommonName
    Write-Host "Certificatename: $CertificateName"

    $returnValue = [PSCustomObject]@{
        CommonName                    = $CommonName
        CertificateName               = $CertificateName
    }

    Write-Output $returnValue
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Add-SecretToFrontDoor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CertificatePath,
        [Parameter(Mandatory)][string] $CertificatePassword,
        [Parameter(Mandatory)][string] $CertificateName,
        [Parameter(Mandatory)][string] $CommonName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultName,
        [Parameter(Mandatory)][string] $FrontDoorProfileName,
        [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
        [Parameter(Mandatory)][string] $IngressDomainName,
        [Parameter(Mandatory)][string] $ServicePrincipalObjectId
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    Write-Host "Granting permissions on keyvault for executing user"
    # Grant the current logged in user (service principal) rights to modify certificates in the keyvault (for uploading & fetching the certificate)
    Grant-MePermissionsOnKeyvault -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName -KeyvaultName $CertificateKeyvaultName
    Write-Host "Granted permissions on keyvault for executing user"

    # Check if there are network rules present for the keyvault
    $keyvaultNetworkRules = (Invoke-Executable az keyvault network-rule list --name $CertificateKeyvaultName | ConvertFrom-Json).virtualNetworkRules
    
    if ($keyvaultNetworkRules) {
        Write-Host "Whitelisting agent ip on keyvault.."
        $RootPath = (Get-Item $PSScriptRoot).Parent.Parent
        & "$RootPath\Keyvault\Add-Network-Whitelist-to-Keyvault.ps1" -KeyvaultName $CertificateKeyvaultName -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName
    }

    # Fetch the certificate from Keyvault if it exists
    Write-Host "Fetching Keyvault certificate"
    $sourceCertificate = Get-Certificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword
    $keyvaultCertificate = Get-CertificateFromKeyvault -KeyvaultName $CertificateKeyvaultName -DomainName $IngressDomainName -ExpectedCertificateThumbprint $sourceCertificate.Thumbprint
    if ($keyvaultCertificate) {
        Write-Host "Keyvault Certificate: $($keyvaultCertificate.id)"
        Write-Host "Keyvault Certificate Notbefore: $($keyvaultCertificate.attributes.notBefore)"
        Write-Host "Keyvault Certificate Notafter: $($keyvaultCertificate.attributes.expires)"
    }
    else {
        Write-Host "Keyvault certificate not found."
        Write-Host "Checking if keyvault certificate exists in soft-deleted state."
 
        $softDeletedCertificate = Get-SoftDeletedCertificateFromKeyvault -KeyvaultName $CertificateKeyvaultName -DomainName $IngressDomainName -ExpectedCertificateThumbprint $sourceCertificate.Thumbprint
        if ($softDeletedCertificate) {
            Write-Host "Found soft-deleted certificate. Recovering.."
            Invoke-Executable az keyvault certificate recover --id $softDeletedCertificate.recoveryId
 
            # Find restored certificate in keyvault
            $keyvaultCertificate = Get-CertificateFromKeyvault -KeyvaultName $CertificateKeyvaultName -DomainName $IngressDomainName -ExpectedCertificateThumbprint $sourceCertificate.Thumbprint
        }
        else {
            Write-Host "Did not find a soft-deleted certificate. Continueing.."
        }
    }
 
    # Check if our source (Azure DevOps) certificate is newer than what we have in Keyvault
    $shouldReplaceCertificateWithSourceCertificate = Test-ShouldReplaceCertificate -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -KeyvaultCertificate $keyvaultCertificate
    if ($shouldReplaceCertificateWithSourceCertificate) {
        Write-Host "We should replace the certificate on the Azure Frontdoor & Keyvault because the source certificate is renewed."
    }
 
    Write-Host "Checking if/where certificates exists and if we should replace it..."
    # Check if the certificate exists in the keyvault
    if (!$keyvaultCertificate -or !$keyvaultCertificate.id -or $shouldReplaceCertificateWithSourceCertificate) {
        Write-Host "KeyVault cert not found or should be replaced."
        # Check if the certificate exists on disk (if not, stop the process)
        if (!$CertificatePath -or !(Test-Path $CertificatePath)) {
            Write-Error "There is no source certificate found (Azure DevOps)."
        }
        # Add the certificate to keyvault if its not there yet
        $keyvaultCertificate = Add-CertificateToKeyvault -KeyvaultName $CertificateKeyvaultName -CertificateName $CertificateName -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -CommonName $CommonName
        Write-Host "Cert added/replaced to keyvault"

        Write-Host "Granting permission to Azure Frontdoor Service Principal to Keyvault"
        Grant-AzureFrontDoorSPPermissionsOnKeyvault -CertificateKeyvaultName $CertificateKeyvaultName -CertificateKeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName -ServicePrincipalObjectId $ServicePrincipalObjectId
        Write-Host "Granted permissions to Azure Frontdoor Service Principal to Keyvault"

        Write-Host "Adding Certificate to FrontDoor"
        $subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
        $certificateSource = "/subscriptions/$($subscriptionId)/resourceGroups/$($CertificateKeyvaultResourceGroupName)/providers/Microsoft.KeyVault/vaults/$($CertificateKeyvaultName)/certificates/$($CertificateName)"
        Add-CertificateToFrontDoor -FrontDoorProfileName $FrontDoorProfileName -FrontDoorResourceGroup $FrontDoorResourceGroup -CertificateName $CertificateName -CertificateSource $certificateSource
        Write-Host "Cert added/replaced to FrontDoor"
    }
 
    # Check if there were network rules present for the keyvault
    if ($keyvaultNetworkRules) {
        Write-Host "Removing whitelist agent ip from keyvault"
        # Get root path and make sure the right provider is registered
        $RootPath = (Get-Item $PSScriptRoot).Parent.Parent
        & "$RootPath\Keyvault\Remove-Network-Whitelist-from-Keyvault.ps1" -KeyvaultName $CertificateKeyvaultName -KeyvaultResourceGroupName $CertificateKeyvaultResourceGroupName
    }
 
    Write-Host "Cert is in place!"
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Grant-AzureFrontDoorSPPermissionsOnKeyvault{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $CertificateKeyvaultName,
        [Parameter(Mandatory)][string] $CertificateKeyvaultResourceGroupName, 
        [Parameter(Mandatory)][string] $ServicePrincipalObjectId
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
    
    # Grant permissions to service principal
    # Todo: fix that this can be done automatically, for now skipping because of permission issues
    # 205478c0-bd83-4e1b-a9d6-db63a3e1e1c8 is the hardcoded id for the application Azure Frontdoor, see https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain
    # $objectId = (Invoke-Executable az ad sp show --id '205478c0-bd83-4e1b-a9d6-db63a3e1e1c8' | ConvertFrom-Json).objectId
    Invoke-Executable az keyvault set-policy --name $CertificateKeyvaultName --certificate-permissions get list create update import delete recover --object-id $ServicePrincipalObjectId --resource-group $CertificateKeyvaultResourceGroupName | Out-Null

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Add-CertificateToFrontDoor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $FrontDoorProfileName,
        [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
        [Parameter(Mandatory)][string] $CertificateName,
        [Parameter(Mandatory)][string] $CertificateSource
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # TODO WHEN NEW RELEASE IS AVAILABLE https://github.com/Azure/azure-cli/pull/21786/files#diff-dbb722b9f4730160e726bf257cd01c118e57cd73311564cbd6bb2997216dfd03
    Invoke-Executable az afd secret create --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --secret-name $CertificateName --secret-source $CertificateSource --use-latest-version 'true'
    Write-Host "Added certificate with name $($CertificateName) to Front Door"

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Add-OriginToOriginGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $FrontDoorProfileName,
        [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
        [Parameter(Mandatory)][string] $OriginGroupName,
        [Parameter(Mandatory)][string] $OriginName,
        [Parameter(Mandatory)][string] $OriginHostName,
        [Parameter()][string] $OriginHttpPort = "80",
        [Parameter()][string] $OriginHttpsPort = "443",
        [Parameter()][string] $OriginPriority = "1", 
        [Parameter()][string] $OriginWeight = "1000", 
        [Parameter()][string][ValidateSet("Enabled", "Disabled")] $OriginEnabled = "Enabled"
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $params = @(
        '--resource-group', $FrontDoorResourceGroup
        '--profile-name', $FrontDoorProfileName
        '--origin-group-name', $OriginGroupName
        '--origin-name', $OriginName
        '--host-name', $OriginHostName
        '--http-port', $OriginHttpPort
        '--https-port', $OriginHttpsPort
        '--priority', $OriginPriority
        '--weight', $OriginWeight
        '--enabled-state', $OriginEnabled
    )

    Invoke-Executable az afd origin create @params

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function New-RuleSetForFrontDoor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $FrontDoorProfileName,
        [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
        [Parameter(Mandatory)][string] $RuleSetName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
    
    Invoke-Executable az afd rule-set create --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --rule-set-name $RuleSetName
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}

function Add-OriginGroupToFrontDoor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $FrontDoorProfileName,
        [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
        [Parameter(Mandatory)][string] $OriginGroupName,
        [Parameter()][string] $OriginHealthProbePath = "/",
        [Parameter()][string][ValidateSet("Http", "Https", "NotSet")] $OriginHealthProbeProtocol = 'Https',
        [Parameter()][string][ValidateSet("GET", "HEAD", "NotSet")] $OriginHealthProbeRequestType = 'GET',
        [Parameter()][string] $OriginHealthProbeIntervalInSeconds = 100,
        [Parameter()][string] $OriginLoadBalancingSampleSize = 4, 
        [Parameter()][string] $OriginLoadBalancingSuccessfulSamplesRequired = 3, 
        [Parameter()][string] $OriginLoadBalancingAdditationalLatencyInMilliseconds = 50
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet 

    $params = @(
        '--profile-name', $FrontDoorProfileName
        '--resource-group', $FrontDoorResourceGroup
        '--origin-group-name', $OriginGroupName
        '--probe-path', $OriginHealthProbePath
        '--probe-protocol', $OriginHealthProbeProtocol
        '--probe-request-type', $OriginHealthProbeRequestType
        '--probe-interval-in-seconds', $OriginHealthProbeIntervalInSeconds
        '--sample-size', $OriginLoadBalancingSampleSize
        '--successful-samples-required', $OriginLoadBalancingSuccessfulSamplesRequired
        '--additional-latency-in-milliseconds', $OriginLoadBalancingAdditationalLatencyInMilliseconds
    )

    Invoke-Executable az afd origin-group create @params

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}


function Add-RouteToEndpointToFrontDoor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $FrontDoorProfileName,
        [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
        [Parameter(Mandatory)][string] $RouteName,
        [Parameter(Mandatory)][string] $EndpointName,
        [Parameter(Mandatory)][string][ValidateSet("HttpOnly", "HttpsOnly", "MatchRequest")] $RouteForwardingProtocol,
        [Parameter()][string][ValidateSet("Disabled", "Enabled")] $RouteHttpsRedirect = "Enabled",
        [Parameter(Mandatory)][string] $OriginGroupName, 
        [Parameter()][string][ValidateSet("Http", "Https")] $RouteSupportedProtocols = "Https",
        [Parameter()][string] $CustomDomainName,
        [Parameter()][string] $RuleSetName,
        [Parameter()][string][ValidateSet('Disabled', 'Enabled')] $LinkToDefaultDomain = 'Disabled'
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet 

    $params = @(
        '--profile-name', $FrontDoorProfileName
        '--resource-group', $FrontDoorResourceGroup
        '--origin-group', $OriginGroupName
        '--endpoint-name', $EndpointName
        '--route-name', $RouteName
        '--forwarding-protocol', $RouteForwardingProtocol
        '--https-redirect', $RouteHttpsRedirect
        '--supported-protocols', $RouteSupportedProtocols
    )

    if ($CustomDomainName) {
        $params += '--custom-domains', $CustomDomainName

    }
    if ($RuleSetName) {
        $params += '--rule-sets', $RuleSetName
    }
    if($LinkToDefaultDomain){
        # Because of bug, when LinkToDefaultDomain is disabled, we won't add it to the params
        if($LinkToDefaultDomain -eq 'Enabled'){
            $params += '--link-to-default-domain', $LinkToDefaultDomain
        }
    }

    Invoke-Executable az afd route create @params

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}