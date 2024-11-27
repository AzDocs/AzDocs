[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][string] $MonitorAlertActionGroupName,
    [Parameter(Mandatory)][string] $MonitorAlertActionGroupResourceGroupName,
    [Parameter(Mandatory)][string] $MonitorAlertQuery,
    [Parameter(Mandatory)][string] $LogAnalyticsWorkspaceResourceId,
    [Parameter(Mandatory)][int] $MonitorAlertFrequencyInMinutes,
    [Parameter(Mandatory)][int] $MonitorAlertTimeWindowInMinutes,
    [Parameter(Mandatory, ParameterSetName = 'metric')][ValidateSet('GreaterThan', 'LessThan', 'Equal')][string] $MonitorAlertMetricTriggerThresholdOperator,
    [Parameter(Mandatory, ParameterSetName = 'metric')][double] $MonitorAlertMetricTriggerThreshold,
    [Parameter(Mandatory, ParameterSetName = 'metric')][ValidateSet('Consecutive', 'Total')][string] $MonitorAlertMetricTriggerType,
    [Parameter(Mandatory, ParameterSetName = 'metric')][string] $MonitorAlertMetricColumn,
    [Parameter(Mandatory)][string][ValidateSet('GreaterThan', 'LessThan', 'Equal')] $MonitorAlertTriggerThresholdOperator,
    [Parameter(Mandatory)][double] $MonitorAlertTriggerThreshold,
    [Parameter(Mandatory)][string] $MonitorAlertingActionSeverity,
    [Parameter(Mandatory)][int] $MonitorAlertingActionSuppressThrottlingInMinutes,
    [Parameter(Mandatory)][string] $MonitorAlertRuleResourceGroupName,
    [Parameter(Mandatory)][string] $MonitorAlertRuleResourceGroupLocation,
    [Parameter()][boolean] $MonitorAlertRuleEnabled = $true,
    [Parameter(Mandatory)][string] $MonitorAlertRuleName,
    [Parameter(Mandatory)][string] $MonitorAlertRuleDescription,
    [Parameter()][string] $MonitorAlertCustomActionEmailSubject
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Set source for the log alert
$source = New-AzScheduledQueryRuleSource -Query $MonitorAlertQuery -DataSourceId $LogAnalyticsWorkspaceResourceId -WarningAction Ignore

# Set a schedule for the log alert
$schedule = New-AzScheduledQueryRuleSchedule -FrequencyInMinutes $MonitorAlertFrequencyInMinutes -TimeWindowInMinutes $MonitorAlertTimeWindowInMinutes -WarningAction Ignore

# Optional: add a metric trigger
$parametersTriggerCondition = @{
    ThresholdOperator = $MonitorAlertTriggerThresholdOperator
    Threshold         = $MonitorAlertTriggerThreshold
    WarningAction     = 'Ignore'
}

if ($PsCmdlet.ParameterSetName -eq 'metric')
{
    $metricTrigger = New-AzScheduledQueryRuleLogMetricTrigger -ThresholdOperator $MonitorAlertMetricTriggerThresholdOperator -Threshold $MonitorAlertMetricTriggerThreshold -MetricTriggerType $MonitorAlertMetricTriggerType -MetricColumn $MonitorAlertMetricColumn -WarningAction Ignore
    $parametersTriggerCondition.Add('MetricTrigger', $metricTrigger)
}

# set a trigger condition
$triggerCondition = New-AzScheduledQueryRuleTriggerCondition @parametersTriggerCondition

# Optional: customize actions for the alerting action
$actionGroupId = (Get-AzResource -Name $MonitorAlertActionGroupName -ResourceGroupName $MonitorAlertActionGroupResourceGroupName).Id
$parametersAznsAction = @{
    ActionGroup   = $actionGroupId
    WarningAction = 'Ignore'
}

if ($MonitorAlertCustomActionEmailSubject)
{
    $parametersAznsAction.Add('EmailSubject', $MonitorAlertCustomActionEmailSubject)
}

# link actiongroup to action
$aznsAction = New-AzScheduledQueryRuleAznsActionGroup @parametersAznsAction

# set alerting action
$alertingAction = New-AzScheduledQueryRuleAlertingAction -AznsAction $aznsAction -Severity $MonitorAlertingActionSeverity -Trigger $triggerCondition -ThrottlingInMinutes $MonitorAlertingActionSuppressThrottlingInMinutes -WarningAction Ignore

# create alert rule
New-AzScheduledQueryRule -ResourceGroupName $MonitorAlertRuleResourceGroupName -Location $MonitorAlertRuleResourceGroupLocation -Action $alertingAction -Enabled $MonitorAlertRuleEnabled -Name $MonitorAlertRuleName -Description $MonitorAlertRuleDescription -Schedule $schedule -Source $source -WarningAction Ignore

Write-Footer -ScopedPSCmdlet $PSCmdlet