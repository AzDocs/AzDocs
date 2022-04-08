[CmdletBinding(DefaultParameterSetName = 'ruleset')]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
    [Parameter(Mandatory, ParameterSetName = "rule")]
    [Parameter(Mandatory, ParameterSetName = "ruleset")][string] $RuleSetName,

    # Rule
    [Parameter()][int] $RuleOrder,
    [Parameter(Mandatory, ParameterSetName = "rule")][string] $RuleName,

    # Condition
    [Parameter(Mandatory, ParameterSetName = "rule")][string]
    [ValidateSet('RequestUri')]
    $ConditionMatchVariable,
    [Parameter(Mandatory, ParameterSetName = "rule")][string] 
    [ValidateSet('Any', 'BeginsWith', 'Contains', 'EndsWith', 'Equal', 'GreaterThan', 'GreaterThanOrEqual', 'LessThan', 'LessThanOrEqual', 'RegEx')]
    $ConditionOperator,
    [Parameter(Mandatory, ParameterSetName = "rule")][string[]] $ConditionMatchValues,

    # Action
    [Parameter(Mandatory, ParameterSetName = "rule")][string] 
    [ValidateSet('RouteConfigurationOverride')]
    $ActionActionName,
    [Parameter(Mandatory, ParameterSetName = "rule")][string] $OriginGroupName,
    [Parameter()][string][ValidateSet('MatchRequest', 'HttpOnly', 'HttpsOnly')] $ActionForwardingProtocol = "MatchRequest"
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
    $subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
    if (!$RuleOrder) {
        Write-Host "Generating order in which the rule should be applied.."

        $getUrl = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($FrontDoorResourceGroup)/providers/Microsoft.Cdn/profiles/$($FrontDoorProfileName)/ruleSets/$($RuleSetName)/rules"
        $rules = Invoke-AzRestCall -Method GET -ResourceUrl $getUrl -ApiVersion '2021-06-01' -Body $body | ConvertFrom-Json
    
        if ($rules.value) {
            $existingRuleOrder = ($rules | Where-Object { $_.value.name -eq $RuleName }).value.properties.order
            if ($existingRuleOrder) {
                $RuleOrder = $existingRuleOrder
                Write-Host "Rule with $RuleName already exists. Setting RuleOrder to  $RuleOrder. Continueing.."
            }
            else {
                $oldRuleOrder = ($rules.value.properties | Sort-Object -Property @{Expression = "order"; Descending = $true })[0]
                $RuleOrder = $oldRuleOrder.order + 1; 
                Write-Host "Created new rule order with order $RuleOrder. Continueing.."
            }
        }
        else {
            # A rule with order 0 is a special rule and does not require any condition nor any actions. This rule will always be applied. 
            # This rule should be made consciously, therefore not adding it to the automatic set.        
            $RuleOrder = 1; 
            Write-Host "First rule. Creating rule with order $RuleOrder. Continueing.."
        }
    }

    # Create rule, condition and action 
    #TODO: At this moment, not possible in the CLI - 2.34.1
    $originGroupId = (Invoke-Executable az afd origin-group show --origin-group-name $OriginGroupName --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup | ConvertFrom-Json).id
    $body = @{
        properties = @{
            order      = $RuleOrder;
            conditions = @(@{
                    name       = $ConditionMatchVariable;
                    parameters = @{
                        typeName        = "DeliveryRuleRequestUriConditionParameters";
                        operator        = $ConditionOperator;
                        matchValues     = $ConditionMatchValues;
                        negateCondition = "false"
                    }
                });
            actions    = @(@{
                    name       = $ActionActionName;
                    parameters = @{
                        originGroupOverride = @{
                            originGroup        = @{
                                id = $originGroupId;
                            };
                            forwardingProtocol = $ActionForwardingProtocol;
                        };
                        cacheConfiguration  = $null;
                        typeName            = "DeliveryRuleRouteConfigurationOverrideActionParameters";
                    }
                });
        }
    }

    $url = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($FrontDoorResourceGroup)/providers/Microsoft.Cdn/profiles/$($FrontDoorProfileName)/ruleSets/$($RuleSetName)/rules/$($RuleName)"
    Invoke-AzRestCall -Method PUT -ResourceUrl $url -ApiVersion '2021-06-01' -Body $body
}
else
{
    Write-Host "Not all parameters were supplied to create a rule. Skipped."
}

Write-Footer -ScopedPSCmdlet $PSCmdlet