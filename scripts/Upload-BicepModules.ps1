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

    . .\scripts\Upload-BicepModules.ps1 -registryName 'acrazdocsdev' -DebugMode true
.EXAMPLE
    $env:BUILD_SOURCEBRANCHNAME = 'main'
    $env:BUILD_BUILDNUMBER = (Get-Date -Format "yyyy.MM.dd.1-") + $env:BUILD_SOURCEBRANCHNAME

    . .\scripts\Upload-BicepModules.ps1 -registryName 'wooooooooooot'    
  #>
[CmdletBinding(SupportsShouldProcess)]
param(

  # Name of the Azure Container Registry
  [Parameter(Mandatory)]
  [string]$RegistryName,

  [Parameter()]
  [string]$SourceBranchName = $env:BUILD_SOURCEBRANCHNAME,

  [Parameter()]
  [string]$TagName = $env:BUILD_BUILDNUMBER,

  [Parameter()]
  [bool]$DebugMode = $false,

  [Parameter()]
  [int]$NrOfParallelProcesses = 4,

  [parameter()]
  [string] $DocumentationURI = 'https://dev.azure.com/kpn/Azure%20Documentation/_git/Upstream.Azure.PlatformProvisioning?path=/Wiki/Azure/AzDocs-v2/Modules'
  
)

Push-Location
try
{
    
  Write-Host "Branch $SourceBranchName"
  Set-Location .\src-bicep
  Get-ChildItem -Recurse -Path '*.bicep' | ForEach-Object -ThrottleLimit $NrOfParallelProcesses -Parallel { 

    function Publish-BicepModule
    {
      [CmdletBinding(SupportsShouldProcess)]
      param (
        [Parameter(Mandatory)]
        [string]
        $BicepFilePath,
    
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $RepositoryUrl,
    
        # Parameter help description
        [Parameter(Mandatory)]
        [string]
        $Tag,
    
        # Parameter help description
        [Parameter()]
        [string]
        $DocumentationURI
      )
    
      Write-Host "Pushing file $BicepFilePath with tag $Tag to $RepositoryUrl"
      if ($PSCmdlet.ShouldProcess("Pushing $BicepFilePath as tag $Tag to repository $RepositoryUrl", $RepositoryUrl, $Tag))
      {
        $bicepParams = @{}
        # if($DocumentationURI){
        #   $bicepParams.Add('-documentationUri', $DocumentationURI)
        # }
        Write-Host "bicep publish $BicepFilePath --target ""br:$($RepositoryUrl):$Tag"" $bicepParams"
        bicep publish $BicepFilePath --target ''br:$($repositoryUrl):$tag"" $bicepParams
      }
    }

    $bicepFile = $_
    $localTagName = $using:TagName
    $localRegistryName = $using:RegistryName
    $localSourceBranchName = $using:SourceBranchName
    $localDebugMode = $using:DebugMode
    Write-Host "Bicep file: $bicepFile"

    $relativePath = Resolve-Path $bicepFile.Directory -Relative
    $repositoryName = (Join-Path -Path $relativePath.TrimStart('.', '\', '/') -ChildPath $bicepFile.BaseName).ToLowerInvariant().Replace('\', '/')

    $repositoryUrl = "$localRegistryName.azurecr.io/$repositoryName"
    Write-Host "Registry url $repositoryUrl"
    $optionalParams = @()
    if ($localDebugMode)
    {
      $optionalParams += '--debug'
    }
    $fileDocumentationUri = "$using:DocumentationURI/$repositoryName.md&_a=preview"

    Publish-BicepModule -BicepFilePath $bicepFile -RepositoryUrl $repositoryUrl -tag $localTagName -DocumentationURI $fileDocumentationUri -WhatIf:$using:WhatIfPreference
    if ($localSourceBranchName -eq 'main')
    {
      Publish-BicepModule -BicepFilePath $bicepFile -RepositoryUrl $repositoryUrl -tag 'latest' -DocumentationURI $fileDocumentationUri -WhatIf:$using:WhatIfPreference
    }
  }
}
finally
{
  Pop-Location
}