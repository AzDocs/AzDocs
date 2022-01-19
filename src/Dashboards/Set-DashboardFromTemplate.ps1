[CmdletBinding()]
param (
    [Parameter(Mandatory)][hashtable] $TagValueDictionary,
    [Parameter(Mandatory)][string] $DashboardName,
    [Parameter(Mandatory)][string] $TemplateFilePath,
    [Parameter(Mandatory)][string] $DashboardResourceGroupName,
    [Parameter()][string]$Location = 'westeurope'
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$dashboardSafeName = $DashboardName.replace(' ', '-').replace('(', '-').replace(')', '-')
$templateContent = Get-Content $TemplateFilePath -Raw

$TagValueDictionary.Keys | ForEach-Object {      
    $key = $_
    $value = $TagValueDictionary[$key]
    $templateContent = $templateContent -creplace $key, $value
}

$newJsonTemplate = $templateContent | ConvertFrom-Json
$newJsonTemplate.Location = $Location
$newJsonTemplate.Name = $dashboardSafeName 

if (!$newJsonTemplate.tags.'hidden-title')
{
    $newJsonTemplate.tags = [PSCustomObject]@{
        'hidden-title' = [System.String]::Empty
    }
}

$newJsonTemplate.tags.'hidden-title' = $DashboardName

$tempfile = '{0}.json' -f [guid]::NewGuid()
try
{
    $newJsonTemplate | ConvertTo-Json -Depth 100 | Out-File $tempfile
    
    $portalExtension = az extension list | ConvertFrom-Json | Where-Object name -EQ 'portal'
    if (!$portalExtension)
    {
        Invoke-Executable az extension add --upgrade --name portal --yes
    }
    
    Invoke-Executable az portal dashboard Create --name $dashboardSafeName --resource-group $DashboardResourceGroupName --input-path (Get-Item $tempfile).FullName 
}
finally
{
    if (Test-Path $tempfile)
    {
        Remove-Item $tempfile
    }
}

Write-Footer -ScopedPSCmdlet $PSCmdlet