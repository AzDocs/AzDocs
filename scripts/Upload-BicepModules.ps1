<#
.SYNOPSIS
  Finds changed bicep modules and uploads these in an Azure Container Registry.
.DESCRIPTION
  The script finds the changed bicep modules and uploads those modules to the azure container registry (Acr) when needed. If the branch is main, then the changed module will be the latest.
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
    
    Write-Host "Branch $($env:BUILD_SOURCEBRANCHNAME)"
   

    Set-Location .\src-bicep
    Get-ChildItem -Recurse -Path '*.bicep' | ForEach-Object { 
        $bicepFile = $_
        Write-Host "Bicep file: $bicepFile"

        $relativePath = Resolve-Path $bicepFile.Directory -Relative
        $repositoryName = (Join-Path -Path $relativePath.TrimStart('.', '\', '/') -ChildPath $bicepFile.BaseName).ToLowerInvariant().Replace('\', '/')

        $repositoryUrl = "$registryName.azurecr.io/$repositoryName"
        Write-Host "Registry url $repositoryUrl"
        if ($env:BUILD_SOURCEBRANCHNAME -eq 'main')
        {
            Write-Host 'Pushing latest tag'
            az bicep publish --file $bicepFile --target "br:$($repositoryUrl):latest"
        }
        Write-Host "Pushing tag $($env:BUILD_BUILDNUMBER)"
        az bicep publish --file $bicepFile --target "br:$($repositoryUrl):$env:BUILD_BUILDNUMBER"
    }
}
finally
{
    Pop-Location
}