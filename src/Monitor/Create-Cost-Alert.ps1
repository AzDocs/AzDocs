[CmdletBinding(DefaultParameterSetName = 'default')]
param (
    [Parameter(Mandatory)][String] $BudgetName,
    [Parameter(Mandatory)][int] $BudgetAmount,
    [Parameter()][String] $BudgetResourceGroupScope,
    [Parameter()][String] $BudgetManagementGroupScope,
    [Parameter()][ValidateSet('Annually', 'BillingAnnual', 'BillingMonth', 'BillingQuarter', 'Monthly', 'Quarterly')][string] $BudgetTimeGrain = 'BillingMonth',
    [Parameter()][DateTime] $BudgetStartDate = (Get-Date -Day 1),
    [Parameter()][DateTime] $BudgetEndDate = (Get-Date -Day 1).AddYears(10),
    [Parameter()][ValidateSet('Forecasted', 'Actual')][String] $AlertThresholdType = 'Forecasted',
    [Parameter()][ValidateSet('EqualTo', 'GreaterThan', 'GreaterThanOrEqualTo')][String] $AlertThresholdOperator = 'GreaterThan',
    [Parameter()][ValidateRange(0, 100)][int] $AlertThreshold = 85,
    [Parameter()][String[]] $AlertContactEmails,
    [Parameter()][String[]] $AlertContactRoles,
    [Parameter()][String[]] $AlertContactActionGroups,
    [Parameter(ParameterSetName = 'default')][PSObject] $Filters,
    [Parameter(Mandatory, ParameterSetName = 'FilterOnSingleTag')][string] $FilterOnTagName,
    [Parameter(Mandatory, ParameterSetName = 'FilterOnSingleTag')][string] $FilterOnTagValue
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Check if we don't have mixed scopes
if($BudgetResourceGroupScope -and $BudgetManagementGroupScope)
{
    throw "Fill out either BudgetResourceGroupScope OR BudgetManagementGroupScope. At least one must be empty."
}

# Make sure we have at least one notification group
if(!$AlertContactEmails -and !$AlertContactRoles -and !$AlertContactActionGroups)
{
    throw "Please make sure to fill either AlertContactEmails, AlertContactRoles or AlertContactActionGroups."
}

# Base JSON
$body = @{ 
    properties = @{
        amount        = $BudgetAmount;
        category      = 'Cost';
        timeGrain     = $BudgetTimeGrain;
        timePeriod    = @{
            startDate = (Get-Date $BudgetStartDate -Format 'yyyy-MM-dd');
            endDate   = (Get-Date $BudgetEndDate -Format 'yyyy-MM-dd');
        }
    }
}

#region ========================= Alerts =========================# ========================= Alerts =========================
$alertName = "$($AlertThresholdType)_$($AlertThresholdOperator)_$($AlertThreshold)_Percent"

$body.properties.notifications += @{
    $alertName = @{
        enabled         = $true;
        operator        = $AlertThresholdOperator;
        threshold       = $AlertThreshold;
        locale          = 'en-us';
        thresholdType   = $AlertThresholdType;
    }
} 

if($AlertContactEmails)
{
    $body.properties.notifications.$alertName.contactEmails = $AlertContactEmails
}
if($AlertContactRoles)
{
    $body.properties.notifications.$alertName.contactRoles = $AlertContactRoles
}
if($AlertContactActionGroups)
{
    $body.properties.notifications.$alertName.contactGroups = $AlertContactActionGroups
}

#endregion ========================= END Alerts =========================

# ========================= Budgetfilters =========================
switch ($PSCmdlet.ParameterSetName)
{
    'default'
    {
        $filters = $Filters
    }
    'FilterOnSingleTag'
    {
        $filters = @{
            and = @(
                @{
                    tags = @{
                        name     = $FilterOnTagName;
                        operator = 'In';
                        values   = @(
                            $FilterOnTagValue
                        )
                    }
                }
            )
        }
    }
}
$body.properties.filter += $filters
# ========================= END Budgetfilters =========================

# Define scope (subscription/managementgroup/rg)
if($BudgetManagementGroupScope)
{
    $scope = "/providers/Microsoft.Management/managementGroups/$($BudgetManagementGroupScope)"
}
else
{
    $subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
    $scope = "/subscriptions/$($subscriptionId)"

    if($BudgetResourceGroupScope)
    {
        $scope += "/resourceGroups/$($BudgetResourceGroupScope)"
    }
}

# Fabricate URL & Do PUT call.
$url = "https://management.azure.com$($scope)/providers/Microsoft.Consumption/budgets/$($BudgetName)"
Invoke-AzRestCall -Method PUT -ResourceUrl $url -ApiVersion '2021-10-01' -Body $body

Write-Footer -ScopedPSCmdlet $PSCmdlet