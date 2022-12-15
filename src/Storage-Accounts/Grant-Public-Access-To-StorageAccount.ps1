[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupName,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter()][switch] $ForcePublic
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$message = "You are about to fully open your storage account to the internet. This is NOT recommended. We recommend that you use a self-hosted agent instead if you are trying to deploy resources to your storage account."
if (!$ForcePublic)
{
    Write-Host "##vso[task.complete result=Failed;]$message If this was intentional, please pass the -ForcePublic flag."
    throw "$message If this was intentional, please pass the -ForcePublic flag."
}

Write-Warning $message
Invoke-Executable az storage account update --resource-group $StorageAccountResourceGroupName --name $StorageAccountName --default-action 'Allow'

Write-Footer -ScopedPSCmdlet $PSCmdlet