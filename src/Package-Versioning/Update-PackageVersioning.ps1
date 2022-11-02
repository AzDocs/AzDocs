[CmdletBinding()]
param (
    [Parameter()][string][ValidateSet("npm", "nuget")] $PackageType = "nuget",
    [Parameter(Mandatory)][string] $PackageName,
    [Parameter()][string] $NpmWorkingDirectory,
    [Parameter()][string] $NugetSource,
    [Parameter()][bool] $IsPreRelease = $true,
    [Parameter()][bool] $UpdateMajorVersion = $false,
    [Parameter()][string] $OutputPipelineVariable = "version"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$errorMessage = "No packages found."
switch ($PackageType) {
    'npm' {
        if (!$NpmWorkingDirectory) {
            throw 'You need to specify the NPM working directory.'
        }
        # Need to set the Npm Working directory when working with npmAuthenticate@0 task
        Set-Location -Path $NpmWorkingDirectory
        $lastVersion = Invoke-Executable -AllowToFail npm show $PackageName dist-tags.latest
        $betaVersion = Invoke-Executable -AllowToFail npm show $PackageName dist-tags.beta 

        if (!$lastVersion) {
            Write-Host "There's no main version. Setting version to 1.0.0."
            $lastVersion = "1.0.0"
        }

        if (!$betaVersion) {
            Write-Host "There's no beta-version. Setting version to 1.0.0."
            $betaVersion = "1.0.0"
        }
    }
    'nuget' {
        if (!$NugetSource) {
            throw 'You need to specify the nuget source.'
        }

        Write-Host "Getting packages from nuget"
        [string]$getLastVersion = Invoke-Executable -AllowToFail nuget list $PackageName -Source $NugetSource
        [string]$getLastBetaVersion = Invoke-Executable -AllowToFail nuget list $PackageName -Source $NugetSource -PreRelease

        if (!($getLastVersion.Contains($errorMessage))) {
            $lastVersion = ($getLastVersion -split "$PackageName")[1].Trim()
        }
        else {
            Write-Host "No latest package found. Setting version to 1.0.0"
            $lastVersion = "1.0.0"
        }

        if (!($getLastBetaVersion.Contains($errorMessage))) {
            $betaVersion = ($getLastBetaVersion -split "$PackageName")[1].Replace('-beta', '').Trim()
        }
        else {
            Write-Host "No beta package found. Setting version to 1.0.0"
            $betaVersion = "1.0.0"
        }
    }
}

Write-Host "Last $PackageType version: $lastVersion"
Write-Host "Last $PackageType beta version: $betaVersion"

$version = "0.0.0"
if ($IsPreRelease) {
    $versionToChange = $betaVersion
    $splittedLastVersion = $lastVersion.split('.')
    $splittedBetaVersion = $betaVersion.split('.')

    if ([int]$splittedLastVersion[0] -ge [int]$splittedBetaVersion[0] -and [int]$splittedLastVersion[1] -gt [int]$splittedBetaVersion[1]) {
        Write-Host "Last version is greater than beta version: $versionToChange"
        $versionToChange = $lastVersion
    }
    
    $version = Get-UpdatedPackageVersion -VersionToChange $versionToChange -VersionSchemeToUpdate "Patch" 

    if ($PackageType -eq 'nuget') {
        $version = "$version-beta"
    }

    Write-Host "New beta version $version"
}
else {
    if ($UpdateMajorVersion) {
        $version = Get-UpdatedPackageVersion -VersionToChange $lastVersion -VersionSchemeToUpdate "Major"
    }
    else {
        $version = Get-UpdatedPackageVersion -VersionToChange $lastVersion -VersionSchemeToUpdate "Minor"
    }

    Write-Host "New main version $version"
}

if ($version -eq "0.0.0") {
    throw "Version did not get updated. Stopping script.."
}

Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariable);]$version"

Write-Footer -ScopedPSCmdlet $PSCmdlet
