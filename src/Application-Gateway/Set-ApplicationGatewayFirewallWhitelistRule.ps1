#Requires -Modules Az.Network

[CmdletBinding(DefaultParameterSetName = 'LowPriority')]
param (
    [Parameter(Mandatory)][string] $IngressDomainName,
    [Parameter()][string[]] $CIDRToWhitelist,
    [Parameter()][string] $ApplicationGatewayWafCustomRuleRequestHeader,
    [Parameter()][string] $ApplicationGatewayWafCustomRuleRequestHeaderValue,
    [Parameter(Mandatory)][string] $ApplicationGatewayResourceGroupName,
    [Parameter(Mandatory)][string] $ApplicationGatewayWafName,
    [Parameter()][ValidateSet("Block", "Allow")][string] $ApplicationGatewayWafCustomRuleAction = "Block",
    [Parameter(Mandatory, ParameterSetName = 'HighPriority')][switch] $HighPriority,
    [Parameter(Mandatory, ParameterSetName = 'DefinedPriority')][ValidateRange(1, 100)][int] $Priority
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

#region functions
function Get-NextLowPriority
{
    param (
        [Parameter(Mandatory)]
        [int[]]
        $Priority,

        [Parameter(Mandatory)]
        [int]
        $DefaultPriority


    )
    $nextPriority = ($Priority | Measure-Object -Maximum).Maximum + 1
    if ($nextPriority -lt $DefaultPriority)
    {
        $nextPriority = $DefaultPriority
    }
    return $nextPriority
}

function Get-NextHighPriority
{
    param (
        [Parameter(Mandatory)]
        [int[]]
        $Priority,

        [Parameter(Mandatory)]
        [int]
        $DefaultPriority
    )
    $nextPriority = ($Priority | Measure-Object -Minimum).Minimum - 1
    if ($nextPriority -gt $DefaultPriority)
    {
        $nextPriority = $DefaultPriority
    }
    return $nextPriority
}
function Test-PriorityInUse
{
    param (
        [Parameter(Mandatory)]
        [System.Collections.Generic.List[Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayFirewallCustomRule]]
        $Rules,

        [Parameter(Mandatory)]
        [int]
        $Priority
    )
    $RuleWithSamePriority = $Rules | Where-Object Priority -eq $Priority
    if ($RuleWithSamePriority)
    {
        throw "There is already a custom rule with the same priority: $($RuleWithSamePriority.Name)"
    }
}
#endregion

if (($ApplicationGatewayWafCustomRuleRequestHeader -and !$ApplicationGatewayWafCustomRuleRequestHeaderValue) -or ($ApplicationGatewayWafCustomRuleRequestHeaderValue -and !$ApplicationGatewayWafCustomRuleRequestHeader))
{
    throw 'Please specify both the ApplicationGatewayWafCustomRuleRequestHeader and the ApplicationGatewayWafCustomRuleRequestHeaderValue or leave them both blank.'
}

$defaultPriorityToStart = 50

# Name for the rule in the WAF
$ruleName = $IngressDomainName.ToLower().replace('.', 'DOT').replace('-', 'DASH') + 'WhiteList'

$firewallCustomRules = @(New-AzApplicationGatewayFirewallCondition -MatchVariable (New-AzApplicationGatewayFirewallMatchVariable -VariableName 'RequestHeaders' -Selector 'host') -Operator Contains -MatchValue $IngressDomainName -Transform Lowercase -NegationCondition $False)

if ($CIDRToWhitelist)
{
    $ipCondition = New-AzApplicationGatewayFirewallCondition -Operator IPMatch -NegationCondition $true -MatchVariable (New-AzApplicationGatewayFirewallMatchVariable -variableName 'RemoteAddr') -MatchValue $CIDRToWhitelist
    $firewallCustomRules += $ipCondition
}

if ($ApplicationGatewayWafCustomRuleRequestHeader -and $ApplicationGatewayWafCustomRuleRequestHeaderValue)
{
    $requestHeaderCondition = New-AzApplicationGatewayFirewallCondition -MatchVariable (New-AzApplicationGatewayFirewallMatchVariable -VariableName 'RequestHeaders' -Selector $ApplicationGatewayWafCustomRuleRequestHeader) -Operator Contains -MatchValue $ApplicationGatewayWafCustomRuleRequestHeaderValue -Transform Lowercase -NegationCondition $False
    $firewallCustomRules += $requestHeaderCondition
}

$azPolicy = Get-AzApplicationGatewayFirewallPolicy -Name $ApplicationGatewayWafName -ResourceGroupName $ApplicationGatewayResourceGroupName
if (!$azPolicy.CustomRules)
{
    Write-Host 'Adding new custom rules collection'
    $azPolicy.CustomRules = [System.Collections.Generic.List[Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayFirewallCustomRule]]::new()
}

$currentRule = $azPolicy.CustomRules | where-object Name -eq $ruleName

if (!$currentRule)
{
    $toSetpriority = $defaultPriorityToStart
    switch ($PSCmdlet.ParameterSetName)
    {
        'LowPriority'
        {
            $azPolicy.CustomRules
            if ( $azPolicy.CustomRules.Count -gt 0)
            {
                $toSetpriority = Get-NextLowPriority -Priority $azPolicy.CustomRules.Priority -DefaultPriority $defaultPriorityToStart
            }
        }
        'HighPriority'
        {
            if ( $azPolicy.CustomRules.Count -gt 0)
            {
                $toSetpriority = Get-NextHighPriority -Priority $azPolicy.CustomRules.Priority -DefaultPriority ($defaultPriorityToStart - 1)
            }
        }
        'DefinedPriority'
        {
            $toSetpriority = $Priority
            if ( $azPolicy.CustomRules.Count -gt 0)
            {
                Test-PriorityInUse -Rules $azPolicy.CustomRules -Priority $Priority
            }

        }
    }
    Write-Host "Adding new custom rule for $IngressDomainName"
    $currentRule = New-AzApplicationGatewayFirewallCustomRule -Name $ruleName -Priority $toSetpriority -RuleType MatchRule -MatchCondition $firewallCustomRules -Action $ApplicationGatewayWafCustomRuleAction
    $azPolicy.CustomRules.Add($currentRule)
}
else
{
    Write-Host "Updating settings for $IngressDomainName"
    $currentRule.MatchConditions = $firewallCustomRules
    $currentRule.Action = $ApplicationGatewayWafCustomRuleAction
    switch ($PSCmdlet.ParameterSetName)
    {
        'LowPriority'
        {
            if ($currentRule.Priority -lt $defaultPriorityToStart)
            {
                $currentRule.Priority = Get-NextLowPriority -Priority $azPolicy.CustomRules.Priority -DefaultPriority $defaultPriorityToStart
            }
        }
        'HighPriority'
        {
            if ($currentRule.Priority -gt ($defaultPriorityToStart - 1))
            {
                $currentRule.Priority = Get-NextHighPriority -Priority $azPolicy.CustomRules.Priority -DefaultPriority ($defaultPriorityToStart - 1)
            }
        }

        'DefinedPriority'
        {
            if ($currentRule.Priority -ne $Priority)
            {
                if ( $azPolicy.CustomRules.Count -gt 0)
                {
                    Test-PriorityInUse -Rules $azPolicy.CustomRules -Priority $Priority
                }
                $currentRule.Priority = $Priority
            }
        }
    }
}

Set-AzApplicationGatewayFirewallPolicy -Name $ApplicationGatewayWafName -ResourceGroupName $ApplicationGatewayResourceGroupName -CustomRule $azPolicy.CustomRules

Write-Footer -ScopedPSCmdlet $PSCmdlet