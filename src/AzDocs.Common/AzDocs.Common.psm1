#Requires -Version 5.0

[cmdletbinding()]
param()

Write-Verbose $PSScriptRoot
$script:ModuleRoot = $PSScriptRoot

Write-Verbose 'Import everything in sub folders folder'
foreach ($folder in @('classes', 'private', 'public'))
{
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $root)
    {
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter '*.ps1' -Recurse

        # dot source each file
        $files | Where-Object { $_.name -NotLike '*.Tests.ps1' } | ForEach-Object {
            Write-Verbose $_.basename
            . $_.FullName
        }
    }
}