[CmdletBinding()]
param (
    [Parameter()]
    [String] $sqlServerResourceGroupName,

    [Parameter()]
    [String] $sqlServerName
)
#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Write-Host "Checking if public access is disabled"
if((Invoke-Executable az sql server show --name $sqlServerName --resource-group $sqlServerResourceGroupName | ConvertFrom-Json).publicNetworkAccess -eq "Enabled")
{
     # Update setting for Public Network Access
     Write-Host "Public access is enabled. Disabling it now."
     Invoke-Executable az sql server update --name $sqlServerName --resource-group $sqlServerResourceGroupName --set publicNetworkAccess="Disabled"
}

Write-Footer