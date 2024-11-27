[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter()][System.Object[]] $ResourceTags,
    [Parameter(Mandatory)][string] $ResourceToMonitorName,
    [Parameter(Mandatory)][string] $ResourceToMonitorResourceGroupName,
    [Parameter(Mandatory)][string] $MetricAlertRuleName,
    [Parameter(Mandatory)][string] $MetricAlertRuleResourceGroupName,
    [Parameter(Mandatory)][string] $MetricAlertRuleDescription,
    [Parameter(Mandatory)][int] $MetricAlertRuleWindowSizeInMinutes,
    [Parameter(Mandatory)][int] $MetricAlertRuleEvaluationFrequencyInMinutes,
    [Parameter()][ValidateRange(0, 4)][int] $MetricAlertRuleSeverity = 3,
    [Parameter(Mandatory)][string] $MonitorAlertActionGroupName,
    [Parameter(Mandatory)][string] $MonitorAlertActionResourceGroupName,
    
    [Parameter(Mandatory, ParameterSetName = 'condition')][string] $MetricAlertRuleConditionSignalName,
    [Parameter(Mandatory, ParameterSetName = 'condition')][ValidateSet('Average', 'Count', 'Maximum', 'Minimum', 'Total')][string] $MetricAlertRuleConditionAggregation,
    [Parameter(Mandatory, ParameterSetName = 'condition')][ValidateSet('Equals', 'GreaterOrLessThan', 'GreaterThan', 'GreaterThanOrEqual', 'LessThan', 'LessThanOrEqual', 'NotEquals')][string] $MetricAlertRuleConditionOperation,
    [Parameter(Mandatory, ParameterSetName = 'condition')][ValidateSet('dynamic', 'static')][string] $MetricAlertRuleConditionType,
    [Parameter(ParameterSetName = 'condition')][ValidateSet('', 'High', 'Medium', 'Low')][AllowEmptyString()][string] $MetricAlertRuleConditionDynamicSensitivity = 'Medium',
    [Parameter(ParameterSetName = 'condition')][int] $MetricAlertRuleConditionStaticThreshold = 0,

    [Parameter(ParameterSetName = 'condition')][string] $MetricAlertRuleConditionDimensionName,
    [Parameter(ParameterSetName = 'condition')][string] $MetricAlertRuleConditionDimensionValue,
    [Parameter(ParameterSetName = 'condition')][ValidateSet('Exclude', 'Include')][string] $MetricAlertRuleConditionDimensionOperator = 'Include'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalConditionParameters = @()

if ($MetricAlertRuleConditionType -eq 'static')
{
    if ($null -eq $MetricAlertRuleConditionStaticThreshold)
    {
        throw 'MetricAlertRuleConditionStaticThreshold can not be empty if MetricAlertRuleConditionType is set to static'
    }
    $optionalConditionParameters += '--threshold', $MetricAlertRuleConditionStaticThreshold
}
else
{
    if (!$MetricAlertRuleConditionDynamicSensitivity)
    {
        throw 'MetricAlertRuleConditionDynamicSensitivity can not be empty if MetricAlertRuleConditionType is set to dynamic'
    }
    $optionalConditionParameters += '--sensitivity', $MetricAlertRuleConditionDynamicSensitivity
}

$resourceToMonitorId = (Invoke-Executable az resource list --resource-group $ResourceToMonitorResourceGroupName --query "[?name=='$($ResourceToMonitorName)']" | ConvertFrom-Json).id

$listDefinitionsForResource = (Invoke-Executable az monitor metrics list-definitions --resource $resourceToMonitorId | ConvertFrom-Json).name.value
if ($listDefinitionsForResource -notcontains $MetricAlertRuleConditionSignalName)
{ 
    throw "$MetricAlertRuleConditionSignalName is not a valid signal name, it must be one of: $listDefinitionsForResource" 
}

$monitorAlertActionGroupId = (Invoke-Executable az monitor action-group show --resource-group $MonitorAlertActionResourceGroupName --name $MonitorAlertActionGroupName | ConvertFrom-Json).id

if ($MetricAlertRuleConditionDimensionName)
{
    if (!$MetricAlertRuleConditionDimensionValue)
    {
        throw 'MetricAlertRuleConditionDimensionValue is required when MetricAlertRuleConditionDimensionName is used'
    }
    $dimension = Invoke-Executable az monitor metrics alert dimension create --name $MetricAlertRuleConditionDimensionName --value $MetricAlertRuleConditionDimensionValue --op $MetricAlertRuleConditionDimensionOperator
    $optionalConditionParameters += '--dimension', $dimension
}

$condition = Invoke-Executable az monitor metrics alert condition create --aggregation $MetricAlertRuleConditionAggregation --metric $MetricAlertRuleConditionSignalName --op $MetricAlertRuleConditionOperation --type $MetricAlertRuleConditionType @optionalConditionParameters

Invoke-Executable az monitor metrics alert create --severity $MetricAlertRuleSeverity --evaluation-frequency "$($MetricAlertRuleEvaluationFrequencyInMinutes)m" --name $MetricAlertRuleName --resource-group $MetricAlertRuleResourceGroupName --scopes $resourceToMonitorId --condition $condition --window-size "$($MetricAlertRuleWindowSizeInMinutes)m" --action $monitorAlertActionGroupId --description $MetricAlertRuleDescription --tags @ResourceTags

Write-Footer -ScopedPSCmdlet $PSCmdlet