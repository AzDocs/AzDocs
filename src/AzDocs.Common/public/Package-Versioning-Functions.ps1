function Get-UpdatedPackageVersion
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $VersionToChange,
        [Parameter(Mandatory)][string][ValidateSet("Major","Minor", "Patch")] $VersionSchemeToUpdate
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    $splittedVersion = $VersionToChange.Split('.');
    $version = $null
    switch ($VersionSchemeToUpdate)
    {
        'Major'{
            # When the Major version changes, default back to [Major].0.0. 
            $newMajorVersion = [int]$splittedVersion[0] + 1
            $currentMajorVersion = [int]$splittedVersion[0] 
            if($newMajorVersion -gt $currentMajorVersion){
                $version = "$($newMajorVersion).0.0"
            }
            else
            {
                throw 'Major version did not change. Stopping script..'
            }
        }
        'Minor' { 
          #When the minor version changes, default back to [Major].[Minor].0
            $minorVersion = [int]$splittedVersion[1] + 1
            $version = "$($splittedVersion[0]).$($minorVersion).0"

        }
        'Patch' { 
            # When the patch version changes, up the patchversion by one
            $patchVersion = [int]$splittedVersion[2] + 1
            $version = "$($splittedVersion[0]).$($splittedVersion[1]).$patchVersion"
        }
    }

    Write-Output $version
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}