[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $ResourceGroupName,

    [Parameter(Mandatory)]
    [string] $AppServiceName,

    [Parameter(Mandatory)]
    [string] $RuleName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az webapp config access-restriction remove --resource-group "$ResourceGroupName" --name "$AppServiceName" --rule-name "$RuleName" --scm-site $true

Invoke-Executable az webapp config access-restriction remove --resource-group "$ResourceGroupName" --name "$AppServiceName" --rule-name "$RuleName" --scm-site $false