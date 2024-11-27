[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppConfigName,
    [Parameter(Mandatory)][string] $AppConfigResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][switch] $ReadOnlyConnectionString
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

if ($ReadOnlyConnectionString)
{
    $connectionType = 'Primary Read Only'
}
else
{
    $connectionType = 'Primary'
}

$connectionString = (Invoke-Executable az appconfig credential list --resource-group $AppConfigResourceGroupName --name $AppConfigName | ConvertFrom-Json | Where-Object name -EQ $connectionType).connectionString
if (!$connectionString)
{
    throw 'Could not find connectionstring for specified AppConfiguration.'
}

$additionalParameters = @()
if ($AppServiceSlotName)
{
    $additionalParameters += '--slot' , $AppServiceSlotName
}

Invoke-Executable az webapp config connection-string set --resource-group $AppServiceResourceGroupName --name $AppServiceName --connection-string-type Custom --settings AppConfiguration=$connectionString @additionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet