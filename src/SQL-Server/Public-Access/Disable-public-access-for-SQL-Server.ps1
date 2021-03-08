[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Write-Host "Checking if public access is disabled"
if((Invoke-Executable az sql server show --name $SqlServerName --resource-group $SqlServerResourceGroupName | ConvertFrom-Json).publicNetworkAccess -eq "Enabled")
{
     # Update setting for Public Network Access
     Write-Host "Public access is enabled. Disabling it now."
     Invoke-Executable az sql server update --name $SqlServerName --resource-group $SqlServerResourceGroupName --set publicNetworkAccess="Disabled"
}

Write-Footer -ScopedPSCmdlet $PSCmdlet