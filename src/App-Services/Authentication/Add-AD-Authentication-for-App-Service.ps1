[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ServiceUserEmail, 
    [Parameter(Mandatory)][string] $ServiceUserPassword, 
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName, 
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppRegistrationName,
    [Parameter(Mandatory)][string] $AppRegistrationRedirectUri,
    [Parameter(Mandatory)][string] $ApplicationGatewayRewriteRuleSetName,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $ApplicationGatewayRequestRoutingRuleName,
    [Parameter(Mandatory)][string] $ApplicationGatewayHealthProbeName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$statusCode = "401"
$rules = @(
    [PSCustomObject]@{
        RuleName          = "Login redirect to AAD"
        HeaderName        = "Location"
        HeaderValue       = "{http_resp_Location_1}{http_resp_Location_2}{var_host}{http_resp_Location_3}"
        ConditionNegate   = $false
        ConditionPattern  = "(.*)(redirect_uri=https%3A%2F%2F).*`\.azurewebsites`\.net(.*)$"
        ConditionVariable = "http_resp_Location" 
    }    ,
    [PSCustomObject]@{
        RuleName          = "Callback from AAD"
        HeaderName        = "Location"
        HeaderValue       = "https://{var_host}{http_resp_Location_2}"
        ConditionNegate   = $false
        ConditionPattern  = "(https:`\/`\/).*`\.azurewebsites`\.net(.*)$"
        ConditionVariable = "http_resp_Location"
    }
)

# keep original context
$originalConfigDir = $env:AZURE_CONFIG_DIR 

# login with service principal in different context
$altIdProfilePath = Join-Path ([io.path]::GetTempPath()) '.azure-altId'
$clientId = $null
$tenantId = $null
try
{
    $env:AZURE_CONFIG_DIR = $altIdProfilePath

    Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions

    # get the tenantId
    $tenantId = (Invoke-Executable az account show | ConvertFrom-Json).tenantId

    # get the app registration information
    $appRegistration = Invoke-Executable az ad app list --display-name $AppRegistrationName | ConvertFrom-Json
    $clientId = $appRegistration.appId
    
    # add redirect uri to app registration
    if ($appRegistration.replyUrls -notcontains $AppRegistrationRedirectUri)
    {
        Write-Host 'Adding redirect uri to app registration';
        Invoke-Executable az ad app update --id $clientId --add replyUrls $AppRegistrationRedirectUri
    }
    else
    {
        Write-Host "Redirect uri $AppRegistrationRedirectUri already exists, continueing"
    }
    
}
finally
{
    $env:AZURE_CONFIG_DIR = $originalConfigDir
    Remove-Item -Recurse -Force $altIdProfilePath
}

if (!$clientId -or !$tenantId)
{
    throw 'No clientId or tenantId available. Stopping.'
}

# update auth webapp
$aadTokenIssuerUrl = "https://sts.windows.net/$tenantId/"

#TODO: Added issue for not being able to set the authentication settings correctly through az cli: https://github.com/Azure/azure-cli/issues/20359
# update to v2 if applicable
Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt
$authVersion = (Invoke-Executable az webapp auth config-version show --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json).configVersion
if ($authVersion -eq "v1")
{
    Write-Host "Application made use of auth v1, upgrading to v2.."
    Invoke-Executable az webapp auth config-version upgrade --name $AppServiceName --resource-group $AppServiceResourceGroupName
}

Invoke-Executable az webapp auth microsoft update --resource-group $AppServiceResourceGroupName --name $AppServiceName --client-id $clientId --issuer $aadTokenIssuerUrl --yes
Invoke-Executable az webapp auth update --resource-group $AppServiceResourceGroupName --name $AppServiceName --enabled true --action RedirectToLoginPage --redirect-provider 'AzureActiveDirectory'

# create new rewrite rule set if not exists
New-RewriteRuleSet -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $ApplicationGatewayRewriteRuleSetName

$rules | ForEach-Object {
    $params = @{
        ApplicationGatewayName              = $ApplicationGatewayName
        ApplicationGatewayResourceGroupName = $ApplicationGatewayResourceGroupName
        RewriteRuleSetName                  = $ApplicationGatewayRewriteRuleSetName
        RewriteRuleName                     = $_.RuleName
        HeaderName                          = $_.HeaderName
        HeaderValue                         = $_.HeaderValue
        ConditionVariable                   = $_.ConditionVariable
        ConditionPattern                    = $_.ConditionPattern
        ConditionNegate                     = $_.ConditionNegate
    }        

    New-RewriteRuleAndCondition @params
}

# Assign the rewrite rule set to the request routing rule if needed
New-RewriteRuleSetAssignment -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $ApplicationGatewayRewriteRuleSetName -ApplicationGatewayRequestRoutingRuleName $ApplicationGatewayRequestRoutingRuleName

# update healthprobe to also accept 401 unauthorized (because of AD Authentication)
$existingStatusCodes = (Invoke-Executable az network application-gateway probe show --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name $ApplicationGatewayHealthProbeName | ConvertFrom-Json).match.statusCodes
if ($existingStatusCodes -notcontains $statusCode)
{
    foreach ($item in $existingStatusCodes)
    {
        if ($item.Contains("-"))
        {
            $splittedValue = $item.Split('-')
            if (!(($statusCode -ge $splittedValue[0]) -and ($statusCode -le $splittedValue[1])))
            {
                Write-Host "The health probe does not contain the statuscode: $statusCode. Adding it to the health probe."
                
                [Collections.Generic.List[string]]$statusCodesToSet = $existingStatusCodes
                $statusCodesToSet.Add($statusCode)

                Write-Host "Statuscodes that will be set: $statusCodesToSet"
                # Did not use Invoke-Executable because it changes the type of $statusCodesToSet
                # Doesn't work as well when changing the $statusCodesToSet to a string value space-separated e.g $($statusCodesToTest -join ' '). Does work without using Invoke-Executable.
                az network application-gateway probe update --gateway-name $ApplicationGatewayName --name $ApplicationGatewayHealthProbeName --resource-group $ApplicationGatewayResourceGroupName --match-status-codes $statusCodesToSet
                Write-Host "Statuscode has been updated"
                break
            }
        }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet