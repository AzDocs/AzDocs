[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $FrontDoorProfileName,
    [Parameter(Mandatory)][string] $FrontDoorResourceGroup,
    [Parameter()][string] $OutputPipelineVariableName = 'FrontDoorId'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$frontDoorId = (Invoke-Executable az afd profile show --profile-name $FrontDoorProfileName --resource-group $FrontDoorResourceGroup | ConvertFrom-Json).frontDoorId

Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$frontDoorId"

Write-Output $frontDoorId

Write-Footer -ScopedPSCmdlet $PSCmdlet