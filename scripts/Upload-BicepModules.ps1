<#
.SYNOPSIS
  Finds changed bicep modules and uploads these in an Azure Container Registry.
.DESCRIPTION
  The script finds the changed bicep modules and uploads those modules to the azure container registry (Acr) when needed. If the branch is main, then the changed module will be the latest.
.NOTES
  The manual way to publish is for example: 'az bicep publish --file src-bicep\Storage\storageAccounts.bicep --target br:$registryName.azurecr.io/storage/storageaccounts.bicep:latest'.
.EXAMPLE
    $env:BUILD_SOURCEBRANCHNAME = 'test_branch'
    $env:BUILD_BUILDNUMBER = (Get-Date -Format "yyyy.MM.dd.1-") + $env:BUILD_SOURCEBRANCHNAME

    . .\scripts\Upload-BicepModules.ps1 -registryName 'acrazdocsdev'
.EXAMPLE
    $env:BUILD_SOURCEBRANCHNAME = 'main'
    $env:BUILD_BUILDNUMBER = (Get-Date -Format "yyyy.MM.dd.1-") + $env:BUILD_SOURCEBRANCHNAME

    . .\scripts\Upload-BicepModules.ps1 -registryName 'wooooooooooot'    
  #>
param(

    # Name of the Azure Container Registry
    [Parameter(Mandatory)]
    [string]$RegistryName,

    [Parameter()]
    [string]$SourceBranchName = $env:BUILD_SOURCEBRANCHNAME,

    [Parameter()]
    [string]$TagName = $env:BUILD_BUILDNUMBER

)

Push-Location
try
{
    
    Write-Host "Branch $SourceBranchName"
    Set-Location .\src-bicep
    Get-ChildItem -Recurse -Path '*.bicep' | ForEach-Object -ThrottleLimit 16 -Parallel  { 
        $bicepFile = $_
        $localTagName = $using:TagName
        $localRegistryName = $using:RegistryName
        $localSourceBranchName = $using:SourceBranchName
        Write-Host "Bicep file: $bicepFile"

        $relativePath = Resolve-Path $bicepFile.Directory -Relative
        $repositoryName = (Join-Path -Path $relativePath.TrimStart('.', '\', '/') -ChildPath $bicepFile.BaseName).ToLowerInvariant().Replace('\', '/')

        $repositoryUrl = "$localRegistryName.azurecr.io/$repositoryName"
        Write-Host "Registry url $repositoryUrl"
        if ($localSourceBranchName -eq 'main')
        {
            Write-Host 'Pushing latest tag'
           az bicep publish --file $bicepFile --target "br:$($repositoryUrl):latest"
        }
        Write-Host "Pushing tag $localTagName"
        az bicep publish --file $bicepFile --target "br:$($repositoryUrl):$localTagName"
    }
}
finally
{
    Pop-Location
}