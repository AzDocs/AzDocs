[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $StorageAccountResourceGroupname,
    [Parameter(Mandatory)][string] $StorageAccountName,
    [Parameter(Mandatory)][string] $BlobOrFileShareName,
    [Parameter(Mandatory)][string] $ContainerMountPath,
    [Parameter()][ValidateSet('AzureBlob', 'AzureFiles')][string] $StorageShareType = 'AzureFiles',
    [Parameter()][string] $AppServiceDeploymentSlotName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$optionalParameters = @()
if ($AppServiceDeploymentSlotName)
{
    $optionalParameters += "--slot", "$AppServiceDeploymentSlotName"
}

# Fetch Storage Account Key. Unfortunately no Managed Identities yet :(
$storageAccountKey = Invoke-Executable az storage account keys list --resource-group $StorageAccountResourceGroupname --account-name $StorageAccountName --query=[0].value --output tsv

# Generate customId based on parameters
$customId = "$($StorageAccountName)-$($StorageShareType)-$($BlobOrFileShareName)"

# Mount Storage
$mountPath = Invoke-Executable -AllowToFail az webapp config storage-account list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json | Where-Object { $_.name -eq $customId }
# az webapp config storage-account add is not omnipotent. So we need to check if we need to add or update.
if($mountPath)
{
    # Update
    Invoke-Executable az webapp config storage-account update --access-key $storageAccountKey --account-name $StorageAccountName --custom-id $customId --share-name $BlobOrFileShareName --storage-type $StorageShareType --name $AppServiceName --resource-group $AppServiceResourceGroupName --mount-path $ContainerMountPath @optionalParameters
}
else
{
    # Add
    Invoke-Executable az webapp config storage-account add --access-key $storageAccountKey --account-name $StorageAccountName --custom-id $customId --share-name $BlobOrFileShareName --storage-type $StorageShareType --name $AppServiceName --resource-group $AppServiceResourceGroupName --mount-path $ContainerMountPath @optionalParameters
}

Write-Footer -ScopedPSCmdlet $PSCmdlet