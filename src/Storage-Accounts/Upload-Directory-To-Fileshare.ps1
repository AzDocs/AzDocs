[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $FileshareName,
    [Parameter(Mandatory)][string] $SourceDirectoryPath,
    [Parameter()][string] $DestinationPath
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

# Fetch Storage Account connection string
$storageAccountConnectionString = (Invoke-Executable az storage account show-connection-string --resource-group $StorageAccountResourceGroupName --name $StorageAccountName | ConvertFrom-Json).connectionString

# Upload directory to Fileshare
$additionalParameters = @()

if ($DestinationPath)
{
    $additionalParameters += '--destination-path', $DestinationPath
}
# Upload file to Fileshare
Invoke-Executable az storage file upload-batch --account-name $StorageAccountName --connection-string $StorageAccountConnectionString --destination $FileshareName --source $SourceDirectoryPath @additionalParameters
    
Write-Footer -ScopedPSCmdlet $PSCmdlet