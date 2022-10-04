[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $WafPolicyName, 
    [Parameter(Mandatory)][string] $WafPolicyCustomRuleName,
    [Parameter(Mandatory)][string] $WafPolicyResourceGroupName, 
    [Parameter(Mandatory)][string][ValidateSet("RemoteAddr", "RequestMethod", "QueryString", "PostArgs", "RequestUri", "RequestHeader", "RequestBody", "Cookies", "SocketAddr")] $WafPolicyCustomRuleConditionMatchVariable,
    [Parameter(Mandatory)][string][ValidateSet("Any", "IPMatch", "GeoMatch", "Equal", "Contains", "LessThan", "GreaterThan", "LessThanOrEqual", "GreaterThanOrEqual", "BeginsWith", "EndsWith", "RegEx")] $WafPolicyCustomRuleConditionOperator,
    [Parameter(Mandatory)][System.Object] $WafPolicyCustomRuleConditionValues,
    [Parameter()][string][ValidateSet("LowerCase", "RemoveNulls", "Trim", "UpperCase", "UrlDecode", "UrlEncode")] $WafPolicyCustomRuleConditionTransforms,
    [Parameter()][string][ValidateSet("MatchRule", "RateLimitRule")] $WafPolicyCustomRuleType = "MatchRule",
    [Parameter()][string][ValidateSet("Allow", "Block", "Log", "Redirect")] $WafPolicyCustomRuleAction = "Block",
    [Parameter()][int]$WafPolicyCustomRulePriority = 100
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Add extension for front-door
Invoke-Executable az config set extension.use_dynamic_install=yes_without_prompt

# TODO : -- does not contain
# ADD NEGATE POSSIBILITY

$optionalParameters = @()
if ($WafPolicyCustomRuleConditionTransforms) {
    $optionalParameters += "--transforms", $WafPolicyCustomRuleConditionTransforms
}

$existingRule = Invoke-Executable -AllowToFail az network front-door waf-policy rule show --name $WafPolicyCustomRuleName --policy-name $WafPolicyName --resource-group $WafPolicyResourceGroupName
if (!$existingRule) {
    Invoke-Executable az network front-door waf-policy rule create --name $WafPolicyCustomRuleName --priority $WafPolicyCustomRulePriority --rule-type $WafPolicyCustomRuleType --action $WafPolicyCustomRuleAction --resource-group $WafPolicyResourceGroupName --policy-name $WafPolicyName --defer
}
else {
    Invoke-Executable az network front-door waf-policy rule update --name $WafPolicyCustomRuleName --priority $WafPolicyCustomRulePriority --action $WafPolicyCustomRuleAction --resource-group $WafPolicyResourceGroupName --policy-name $WafPolicyName
}

$existingMatchConditions = Invoke-Executable az network front-door waf-policy rule match-condition list --name $WafPolicyCustomRuleName --policy-name $WafPolicyName --resource-group $WafPolicyResourceGroupName | ConvertFrom-Json
$index = 0
$added = $false
if ($existingMatchConditions | Where-Object { $_.operator -eq $WafPolicyCustomRuleConditionOperator }) {
    Write-Host "Found a match condition with the same operator : $WafPolicyCustomRuleConditionOperator"
    foreach ($matchCondition in $existingMatchConditions) {
        if ($matchCondition.operator -eq $WafPolicyCustomRuleConditionOperator) {
            Write-Host "Removing existing.."
            Invoke-Executable az network front-door waf-policy rule match-condition remove --index $index --name $WafPolicyCustomRuleName --policy-name $WafPolicyName --resource-group $WafPolicyResourceGroupName
            Write-Host "Adding.."
            Invoke-Executable az network front-door waf-policy rule match-condition add --match-variable $WafPolicyCustomRuleConditionMatchVariable --operator $WafPolicyCustomRuleConditionOperator --values @WafPolicyCustomRuleConditionValues --name $WafPolicyCustomRuleName --resource-group $WafPolicyResourceGroupName --policy-name $WafPolicyName @optionalParameters
            $added = $true
        }
        $index++
    }
}

if (!$added) {
    Invoke-Executable az network front-door waf-policy rule match-condition add --match-variable $WafPolicyCustomRuleConditionMatchVariable --operator $WafPolicyCustomRuleConditionOperator --values @WafPolicyCustomRuleConditionValues --name $WafPolicyCustomRuleName --resource-group $WafPolicyResourceGroupName --policy-name $WafPolicyName @optionalParameters
}

Write-Footer -ScopedPSCmdlet $PSCmdlet