[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $appConfigName,

    [Parameter(Mandatory)]
    [String] $appConfigResourceGroupName,

    [Parameter(Mandatory)]
    [String] $appServiceName,

    [Parameter(Mandatory)]
    [String] $appServiceResourceGroupName,

    [Parameter()]
    [string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

#TODO why primary and not primary read only?
$connectionString = (Invoke-Executable az appconfig credential list --resource-group $appConfigResourceGroupName --name $appConfigName | ConvertFrom-Json | Where-Object name -eq "Primary").connectionString
if (!$connectionString) {
    throw "Could not find connectionstring for specified AppConfiguration."
}

$additionalParameters = @()
if ($AppServiceSlotName) {
    $additionalParameters += '--slot' , $AppServiceSlotName
}

Invoke-Executable az webapp config connection-string set --resource-group $appServiceResourceGroupName --name $appServiceName --connection-string-type Custom --settings AppConfiguration=$connectionString @additionalParameters

Write-Footer