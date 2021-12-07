[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $BudgetName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$budget = Invoke-Executable -AllowToFail az consupmtion budget show --budget-name $BudgetName
if ($budget)
{
    Write-Host "Found budget removing.."
    Invoke-Executable az consumption budget delete --budget-name $BudgetName
}
else
{
    Write-Host "Found no budget with name $BudgetName. Continueing.."
}

Write-Footer -ScopedPSCmdlet $PSCmdlet