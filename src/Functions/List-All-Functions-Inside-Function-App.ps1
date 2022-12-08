[CmdletBinding()]
param (
    [Parameter(Mandatory)][String] $FunctionAppResourceGroupName,
    [Parameter(Mandatory)][string] $FunctionAppName, 
    [Parameter()][ValidateSet("httpTrigger", "serviceBusTrigger", "orchestrationTrigger", "activityTrigger", "timerTrigger", "all")][string[]] $FunctionTypesToReturn = ("all"),
    [Parameter()][ValidateSet("all", "functionNames")][string] $FunctionValuetoReturn = "all",
    [Parameter()][string] $OutputPipelineVariableName = "FunctionList"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$subscriptionId = (Invoke-Executable az account show | ConvertFrom-Json).id
$functions = Invoke-AzRestCall -Method "GET" -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$FunctionAppResourceGroupName/providers/Microsoft.Web/sites/$FunctionAppName/functions" -ApiVersion "2015-08-01" | ConvertFrom-Json

if ($FunctionTypesToReturn -eq "all") {
    switch ($FunctionValuetoReturn) {
        "all" { Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$functions" }
        "functionNames" { Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$($functions.value.properties.name)" }
    }
}
else {
    switch ($FunctionValueToReturn) {
        "all" { Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$($functions | Where-Object {$_.value.properties.config.bindings.type -in $FunctionTypesToReturn})" }
        "functionNames" { Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$(($functions.value.properties | Where-Object {$_.config.bindings.type -contains $FunctionTypesToReturn}).name)" }
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet