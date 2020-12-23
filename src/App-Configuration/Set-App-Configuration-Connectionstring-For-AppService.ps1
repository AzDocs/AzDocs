[CmdletBinding()]
param (
    [Parameter()]
    [String] $appConfigName,

    [Parameter()]
    [String] $appConfigResourceGroupName,

    [Parameter()]
    [String] $appServiceName,

    [Parameter()]
    [String] $appServiceResourceGroupName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

$connectionString = ((Invoke-Executable az appconfig credential list --resource-group $appConfigResourceGroupName --name $appConfigName | ConvertFrom-Json) | Where-Object { $_.name -eq "Primary" }).connectionString

if ($connectionString) {
    Invoke-Executable az webapp config connection-string set --resource-group $appServiceResourceGroupName --name $appServiceName --connection-string-type Custom --settings AppConfiguration=$connectionString
}
else {
    Write-Error "Could not find connectionstring for specified AppConfiguration."
}

Write-Footer