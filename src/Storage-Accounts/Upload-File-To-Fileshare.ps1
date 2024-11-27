[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $FileshareName,
    [Parameter(Mandatory)][string] $SourceFilePath,
    [Parameter()][string] $DestinationPath
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch Storage Account connection string
$storageAccountConnectionString = (Invoke-Executable az storage account show-connection-string --resource-group $StorageAccountResourceGroupName --name $StorageAccountName | ConvertFrom-Json).connectionString

# Upload file to Fileshare
$additionalParameters = @()

if ($DestinationPath)
{
    $additionalParameters += '--path', $DestinationPath
}

Invoke-Executable az storage file upload --account-name $StorageAccountName --connection-string $StorageAccountConnectionString --share-name $FileshareName --source $SourceFilePath @additionalParameters

Write-Footer -ScopedPSCmdlet $PSCmdlet