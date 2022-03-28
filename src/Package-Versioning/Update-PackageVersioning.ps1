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

switch($PackageType){
    'npm'{
        if(!$NpmWorkingDirectory)
        {
            throw 'You need to specify the NPM working directory.'
        }
        # Need to set the Npm Working directory when working with npmAuthenticate@0 task
        Set-Location -Path $NpmWorkingDirectory
        $lastVersion = npm show $PackageName dist-tags.latest
        $betaVersion = npm show $PackageName dist-tags.beta 
    }
    'nuget'{
        if(!$NugetSource)
        {
            throw 'You need to specify the nuget source.'
        }
        [string]$getLastVersion = nuget list $PackageName -Source $NugetSource
        [string]$getLastBetaVersion = nuget list $PackageName -Source $NugetSource -PreRelease

        $lastVersion = ($getLastVersion -split "$PackageName")[1].Trim();
        $betaVersion = ($getLastBetaVersion -split "$PackageName")[1].Replace('-beta', '').Trim();
    }
}
            
Write-Host "Last $PackageType version: $lastVersion"
Write-Host "Last $PackageType beta version: $betaVersion"

$version = "0.0.0"
if ($IsPreRelease) 
{
    $versionToChange = $betaVersion
    if ($lastVersion -ge $betaVersion) {
        Write-Host "Last version is greater than beta version: $versionToChange"
        $versionToChange = $lastVersion
    }
    
    $version = Get-UpdatedPackageVersion -VersionToChange $versionToChange -VersionSchemeToUpdate "Patch" 

    if($PackageType -eq 'nuget')
    {
        $version = "$version-beta"
    }

    Write-Host "New beta version $version"
}
else
{
    if($UpdateMajorVersion){
        $version = Get-UpdatedPackageVersion -VersionToChange $lastVersion -VersionSchemeToUpdate "Major"
    }
    else 
    {
        $version = Get-UpdatedPackageVersion -VersionToChange $lastVersion -VersionSchemeToUpdate "Minor"
    }

    Write-Host "New main version $version"
}

if($version -eq "0.0.0")
{
    throw "Version did not get updated. Stopping script.."
}

Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariable);]$version"

Write-Footer -ScopedPSCmdlet $PSCmdlet
