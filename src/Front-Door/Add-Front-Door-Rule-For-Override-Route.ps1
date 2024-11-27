[CmdletBinding(DefaultParameterSetName = 'ruleset')]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
    [Parameter(Mandatory, ParameterSetName = 'rule')]
    [Parameter(Mandatory, ParameterSetName = 'ruleset')][string] $RuleSetName,

    # Rule
    [Parameter()][int] $RuleOrder,
    [Parameter(Mandatory, ParameterSetName = 'rule')][string] $RuleName,

    # Condition
    [Parameter(Mandatory, ParameterSetName = 'rule')][string]
    [ValidateSet('RequestUri')]
    $ConditionMatchVariable,
    [Parameter(Mandatory, ParameterSetName = 'rule')][string] 
    [ValidateSet('Any', 'BeginsWith', 'Contains', 'EndsWith', 'Equal', 'GreaterThan', 'GreaterThanOrEqual', 'LessThan', 'LessThanOrEqual', 'RegEx')]
    $ConditionOperator,
    [Parameter(Mandatory, ParameterSetName = 'rule')][string[]] $ConditionMatchValues,
    [Parameter(ParameterSetName = 'rule')][string][ValidateSet('Continue', 'Stop')] $ConditionMatchProcessingBehavior = 'Stop',
    [Parameter(ParameterSetName = 'rule')][string][ValidateSet('Lowercase', 'RemoveNulls', 'Trim', 'Uppercase', 'UrlDecode', 'UrlEncode')] $ConditionTransformBehavior = 'Lowercase',

    # Action
    [Parameter(Mandatory, ParameterSetName = 'rule')][string] 
    [ValidateSet('RouteConfigurationOverride')]
    $ActionActionName,
    [Parameter(Mandatory, ParameterSetName = 'rule')][string] $OriginGroupName,
    [Parameter()][string][ValidateSet('MatchRequest', 'HttpOnly', 'HttpsOnly')] $ActionForwardingProtocol = 'MatchRequest'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Create rule set
Invoke-Executable az afd rule-set create --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --rule-set-name $RuleSetName

# Get latest rule order
if ($RuleName -and $ConditionMatchVariable -and $ConditionOperator -and $ConditionMatchValues -and $ActionActionName -and $OriginGroupName)
{
    if (!$RuleOrder)
    {
        Write-Host 'Generating order in which the rule should be applied..'

        $rules = Invoke-Executable az afd rule list --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --rule-set-name $RuleSetName | ConvertFrom-Json
        if ($rules)
        {
            foreach ($rule in $rules)
            {
                if ($rule.name -eq $RuleName)
                {
                    Write-Host "Found existing rule with $RuleName and order $($rule.order)"
                    $RuleOrder = $rule.order
                    break
                }
            }

            if (!$RuleOrder)
            {
                $oldRuleOrder = ($rules | Sort-Object -Property order -Descending)[0].order
                $RuleOrder = $oldRuleOrder + 1 
                Write-Host "Created new rule order with order $RuleOrder. Continueing.."
            }
        }
        else
        {
            # A rule with order 0 is a special rule and does not require any condition nor any actions. This rule will always be applied. 
            # This rule should be made consciously, therefore not adding it to the automatic set.        
            $RuleOrder = 1 
            Write-Host "First rule. Creating rule with order $RuleOrder. Continueing.."
        }
    }

    # Create rule, condition and action 
    Invoke-Executable az afd rule create --action-name $ActionActionName --order $RuleOrder --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup --rule-name $RuleName --rule-set-name $RuleSetName --forwarding-protocol $ActionForwardingProtocol --origin-group $OriginGroupName --match-variable $ConditionMatchVariable --operator $ConditionOperator --match-values $ConditionMatchValues --match-processing-behavior $ConditionMatchProcessingBehavior --transforms $ConditionTransformBehavior
}
else
{
    Write-Host 'Not all parameters were supplied to create a rule. Skipped.'
}

Write-Footer -ScopedPSCmdlet $PSCmdlet