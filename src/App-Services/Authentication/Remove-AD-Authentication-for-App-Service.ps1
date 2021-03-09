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

$statusCode = 401
$rules = @(
    [PSCustomObject]@{RuleName = "Login redirect to AAD" },
    [PSCustomObject]@{RuleName = "Callback from AAD" }
)

# keep original context
$originalConfigDir = $env:AZURE_CONFIG_DIR 

# login with service principal in different context
$altIdProfilePath = Join-Path ([io.path]::GetTempPath()) '.azure-altId'
try
{
    $env:AZURE_CONFIG_DIR = $altIdProfilePath

    # login with service principal in different context
    Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions

    # get the app registration information
    $appRegistration = Invoke-Executable az ad app list --display-name $AppRegistrationName | ConvertFrom-Json
    $clientId = $appRegistration.appId
    
    # remove redirect uri from app registration
    if ($appRegistration.replyUrls.Contains($AppRegistrationRedirectUri))
    {
        # removal only works with specifying the index to remove from the array
        Write-Host 'Removing the redirect uri from the app registration'
        $indexOfArray = [array]::IndexOf($appRegistration.replyUrls, $AppRegistrationRedirectUri)
        Invoke-Executable az ad app update --id $clientId --remove replyUrls $indexOfArray
    }
    else
    {
        Write-Host "Redirect uri $AppRegistrationRedirectUri doesn't exist, continueing"
    }
    
}
finally
{
    $env:AZURE_CONFIG_DIR = $originalConfigDir
    Remove-Item -Recurse -Force $altIdProfilePath
}

# Update auth webapp
Invoke-Executable az webapp auth update --resource-group $AppServiceResourceGroupName --name $AppServiceName --enabled false

# Remove the rewrite rules
$rules | ForEach-Object {
    Remove-RewriteRule -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -RewriteRuleSetName $ApplicationGatewayRewriteRuleSetName -RewriteRuleName $_.RuleName
}

# update healthprobe to remove 401 unauthorized (because of AD Authentication)
$existingStatusCodes = (Invoke-Executable az network application-gateway probe show --resource-group $ApplicationGatewayResourceGroupName --gateway-name $ApplicationGatewayName --name $ApplicationGatewayHealthProbeName | ConvertFrom-Json).match.statusCodes
$statusCodesToSet = Get-StatusCodeRanges -existingStatusCodes $existingStatusCodes -statusCode $statusCode

Write-Host "Statuscodes that will be set: $statusCodesToSet"

# Did not use Invoke-Executable because it changes the type of $statusCodesToSet
# Doesn't work as well when changing the $statusCodesToSet to a string value space-separated e.g $($statusCodesToTest -join ' '). Does work without using Invoke-Executable.
az network application-gateway probe update --gateway-name $ApplicationGatewayName --name $ApplicationGatewayHealthProbeName --resource-group $ApplicationGatewayResourceGroupName --match-status-codes $statusCodesToSet
Write-Host "Statuscode has been updated"

Write-Footer -ScopedPSCmdlet $PSCmdlet