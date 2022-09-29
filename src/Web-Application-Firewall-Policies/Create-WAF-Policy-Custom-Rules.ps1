[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $WafPolicyName, 
    [Parameter(Mandatory)][string] $WafPolicyCustomRuleName,
    [Parameter(Mandatory)][string] $WafPolicyResourceGroup, 
    [Parameter(Mandatory)][string][ValidateSet("RemoteAddr", "RequestMethod", "QueryString", "PostArgs", "RequestUri", "RequestHeader", "RequestBody", "Cookies", "SocketAddr")] $WafPolicyCustomRuleConditionMatchVariable,
    [Parameter(Mandatory)][string][ValidateSet("Any", "IPMatch", "GeoMatch", "Equal", "Contains", "LessThan", "GreaterThan", "LessThanOrEqual", "GreaterThanOrEqual", "BeginsWith", "EndsWith", "RegEx")] $WafPolicyCustomRuleConditionOperator,
    [Parameter(Mandatory)][string][ValidateSet("LowerCase", "RemoveNulls", "Trim", "UpperCase", "UrlDecode", "UrlEncode")] $WafPolicyCustomRuleConditionTransforms,
    [Parameter(Mandatory)][System.Object] $WafPolicyCustomRuleConditionValues,
    [Parameter()][string][ValidateSet("MatchRule", "RateLimitRule")] $WafPolicyCustomRuleType = "MatchRule",
    [Parameter()][string][ValidateSet("Allow", "Block", "Log", "Redirect")] $WafPolicyCustomRuleAction = "Block"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# .\Create-WAF-Policy-Custom-Rules.ps1 -WafPolicyName 'DPSharedWAFdev' -WafPolicyCustomRuleName 'test' -WafPolicyResourceGroup 'DP-Shared-dev' -WafPolicyCustomRuleConditionMatchVariable 'RemoteAddr' -WafPolicyCustomRuleConditionOperator 'IPMatch' -WafPolicyCustomRuleConditionValues @('20.56.12.193';) -WafPolicyCustomRuleType 'MatchRule' -WafPolicyCustomRuleAction 'Allow'

# Add extension for front-door
Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt

Invoke-Executable az network front-door waf-policy rule create --name $WafPolicyCustomRuleName --priority $WafPolicyCustomRulePriority --rule-type $WafPolicyCustomRuleType --action $WafPolicyCustomRuleAction --resource-group $WafPolicyResourceGroup --policy-name $WafPolicyName --defer
Invoke-Executable az network front-door waf-policy rule match-condition add --match-variable $WafPolicyCustomRuleConditionMatchVariable --operator $WafPolicyCustomRuleConditionOperator --values @WafPolicyCustomRuleConditionValues --name $WafPolicyCustomRuleName --resource-group $WafPolicyResourceGroup --policy-name $WafPolicyName --transforms $WafPolicyCustomRuleConditionTransforms

Write-Footer -ScopedPSCmdlet $PSCmdlet