[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName
)
#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\..\common\Write-HeaderFooter.ps1"
. "$PSScriptRoot\..\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Write-Header

Write-Host "Checking if public access is disabled"
if((Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).publicNetworkAccess -eq "Enabled")
{
     # Update setting for Public Network Access
     Write-Host "Public access is enabled. Disabling it now."
     Invoke-Executable az sql server update --name $SqlServerName --resource-group $SqlServerResourceGroupName --set publicNetworkAccess="Disabled"
}

Write-Footer