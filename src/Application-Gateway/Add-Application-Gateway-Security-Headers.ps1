[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationGatewayName,
    [Parameter(Mandatory)][string] $IngressDomainName,
    [Parameter()][string] $ContentSecurityPolicyValue = "default-src 'self'"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet
   
$dashedDomainName = Get-DashedDomainname -DomainName $IngressDomainName
$applicationGatewayRequestRoutingRuleName = "$dashedDomainName-httpsrule"
$applicationGatewayRewriteRuleSetName = $applicationGatewayRequestRoutingRuleName.Substring(0, $applicationGatewayRequestRoutingRuleName.Length - 'rule'.Length ) + '-rewriteset'

$rewriteHeaders = @"
Name;                                               Header;                             Value
Set CSP Policy if missing;                          Content-Security-Policy;            "$ContentSecurityPolicyValue"
Set X-Frame-Options if missing;                     X-Frame-Options;                    "DENY"
set X-Content-Type-Options if missing;              X-Content-Type-Options;             "nosniff"
Set X-Permitted-Cross-Domain-Policies if missing;   X-Permitted-Cross-Domain-Policies;  "none"
Set Referrer-Policy if missing;                     Referrer-Policy;                    "no-referrer"
Set Strict-Transport-Security if missing;           Strict-Transport-Security;          "max-age=31536000 ; includeSubDomains"
Set Permissions-Policy if missing;                  Permissions-Policy;                 "microphone=(), camera=()"
"@ | ConvertFrom-Csv -Delimiter ';'

$rewriteRemoveHeaders = @'
Name;                           Header
Remove Server header;           Server
Remove X-Powered-By header;     X-Powered-By
Remove X-AspNet-Version header; X-AspNet-Version
'@ | ConvertFrom-Csv -Delimiter ';'

New-RewriteRuleSet -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $applicationGatewayRewriteRuleSetName

$rewriteHeaders | ForEach-Object {
    $params = @{
        ApplicationGatewayName              = $ApplicationGatewayName
        ApplicationGatewayResourceGroupName = $ApplicationGatewayResourceGroupName
        RewriteRuleSetName                  = $ApplicationGatewayRewriteRuleSetName
        RewriteRuleName                     = $_.Name
        HeaderName                          = $_.Header
        HeaderValue                         = $_.Value
        ConditionVariable                   = "http_resp_$($_.Header)"
        ConditionPattern                    = '.+'
        ConditionNegate                     = $true
    }        
    New-RewriteRuleAndCondition @params
}

$rewriteRemoveHeaders | ForEach-Object {
    $params = @{
        ApplicationGatewayName              = $ApplicationGatewayName
        ApplicationGatewayResourceGroupName = $ApplicationGatewayResourceGroupName
        RewriteRuleSetName                  = $ApplicationGatewayRewriteRuleSetName
        RewriteRuleName                     = $_.Name
        HeaderName                          = $_.Header
        HeaderValue                         = ''
        ConditionVariable                   = "http_resp_$($_.Header)"
        ConditionPattern                    = '.+' 
        ConditionNegate                     = $false
    }        
    New-RewriteRuleAndCondition @params
}

New-RewriteRuleSetAssignment -ApplicationGatewayResourceGroupName $ApplicationGatewayResourceGroupName -ApplicationGatewayName $ApplicationGatewayName -RewriteRuleSetName $applicationGatewayRewriteRuleSetName -applicationGatewayRequestRoutingRuleName $applicationGatewayRequestRoutingRuleName

Write-Footer -ScopedPSCmdlet $PSCmdlet