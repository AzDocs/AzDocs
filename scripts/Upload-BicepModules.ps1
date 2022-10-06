<#
.SYNOPSIS
  Finds changed bicep modules and uploads these in an Azure Container Registry.
.DESCRIPTION
  The script finds the changed bicep modules and uploads those modules to the azure container registry (Acr) when needed. If the branch is main, then the changed module will be the latest.
  It does this by comparing the sha256 of the bicep file in the repository files with the sha256 name in the Acr of the module with the same name.
.NOTES
  The manual way to publish is for example: 'az bicep publish --file src-bicep\Storage\storageAccounts.bicep --target br:$registryName.azurecr.io/storage/storageaccounts.bicep:latest'.
.EXAMPLE
    . .\scripts\Upload-BicepModules.ps1
  #>
param(

    # Name of the Azure Container Registry
    [Parameter()]
    [string]$registryName
)


Push-Location
try
{
    Set-Location .\src-bicep
    $filehashedBicepFiles = Get-ChildItem -Recurse -Path '*.bicep' | Get-FileHash -Algorithm SHA256

    $filehashedBicepFiles | ForEach-Object {
        $fileHash = $_
        $file = Get-Item $fileHash.Path
        $relativePath = Resolve-Path $file.Directory -Relative

        $repositoryName = (Join-Path -Path $relativePath.TrimStart('.', '\', '/') -ChildPath $file.BaseName).ToLowerInvariant().Replace('\', '/')
        Write-Host "Processing $repositoryName"
        $repositoryUrl = "$registryName.azurecr.io/$repositoryName"

        $manifest = az acr manifest list-metadata $repositoryUrl --only-show-errors | ConvertFrom-Json
        if ($manifest)
        {
            $recordWithLatest = ($manifest | Where-Object { $_.tags -contains 'latest' })
            if ($recordWithLatest)
            {
                $hashTags = $recordWithLatest.tags | Where-Object { $_ -Like 'sha256_*' }
                if ($hashTags)
                {
                    Write-Host "Hash tag: $hashTags"
                    $hash = $hashTags.Substring('sha256_'.Length)
                    if ($hash)
                    {
                        if ( $fileHash.Hash -eq $hash)
                        {
                            Write-Host 'Same file, not going to process'
                            return
                        }
                        else
                        {
                            Write-Host "Hash acr: $hash"
                            Write-Host "Hash file: $($fileHash.Hash)"
                            Write-Host 'Found different hash, going to upload the newest'
                        }
                    }
                    else
                    {
                        Write-Warning 'Could not determine the hash, going to process as normal'
                    }
                }
                else
                {
                    Write-Warning 'Could not find the hash tags on the manifest'
                }
                # continue publishing
            }
            else
            {
                Write-Warning 'Could not find the latest tags on the manifest'
            }
            # continue publishing
        }
        else
        {
            Write-Warning 'Could not find the module'
        }

        Write-Host "Pushing $repositoryName"
        if ($env:BUILD_SOURCEBRANCHNAME -eq 'main')
        {
            Write-Host 'Pushing latest tag'
            az bicep publish --file $fileHash.Path --target "br:$($repositoryUrl):latest"
        }

        Write-Host 'Pushing sha256 tag'
        az bicep publish --file $fileHash.Path --target "br:$($repositoryUrl):sha256_$($fileHash.Hash)"

        Write-Host 'Pushing run tag'
        az bicep publish --file $fileHash.Path --target "br:$($repositoryUrl):run_$env:BUILD_BUILDNUMBER"

        Write-Host 'Pushing git tag'
        az bicep publish --file $fileHash.Path --target "br:$($repositoryUrl):git_$env:BUILD_SOURCEVERSION"

        Write-Host 'Pushing branch tag'
        az bicep publish --file $fileHash.Path --target "br:$($repositoryUrl):branch_$env:BUILD_SOURCEBRANCHNAME"
    }

}
finally
{
    Pop-Location
}