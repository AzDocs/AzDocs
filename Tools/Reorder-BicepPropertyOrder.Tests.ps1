#requires -Version 7.4

$reorderCases = @(
    @{
        Name = 'top-level declarations and chronological deployable grouping'
        Content = @"
output result string = 'done'
module child './child.bicep' = {
  params: {
    input: location
  }
  name: 'child-deployment'
  scope: resourceGroup()
}
resource newStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  properties: {
  }
  tags: {
    owner: 'platform'
  }
  location: location
  name: 'newsa'
}
var featureEnabled = true
func normalizeName(input string) string => toLower(input)
param location string = 'westeurope'
metadata owner = 'nebula'
@description('existing resource stays with decorator')
resource existingStorage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  scope: subscription()
  name: 'existingsa'
}
targetScope = 'subscription'
"@
        Needles = @(
            "targetScope = 'subscription'",
            "metadata owner = 'nebula'",
            "param location string = 'westeurope'",
            "var featureEnabled = true",
            "func normalizeName(input string) string => toLower(input)",
            "resource existingStorage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {",
            "module child './child.bicep' = {",
            "resource newStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {",
            "output result string = 'done'"
        )
        RegexAssertions = @(
            "@description\('existing resource stays with decorator'\)\r?\nresource existingStorage"
        )
    },
    @{
        Name = 'resource and module body properties'
        Content = @"
targetScope = 'resourceGroup'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  properties: {
    supportsHttpsTrafficOnly: true
  }
  tags: {
    owner: 'platform'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  location: 'westeurope'
  name: 'stgexample'
}

module child './child.bicep' = {
  params: {
    location: 'westeurope'
  }
  name: 'child-deployment'
  scope: resourceGroup()
}
"@
        Needles = @(
            "name: 'stgexample'",
            "location: 'westeurope'",
            "sku: {",
            "kind: 'StorageV2'",
            "tags: {",
            "properties: {",
            "scope: resourceGroup()",
            "name: 'child-deployment'",
            "params: {"
        )
        RegexAssertions = @()
    }
)

$lineEndingCases = @(
    @{ Name = 'LF'; LineEnding = "`n" },
    @{ Name = 'CRLF'; LineEnding = "`r`n" }
)

Describe 'Reorder-BicepPropertyOrder' {
    BeforeAll {
        $script:ScriptUnderTest = Join-Path -Path $PSScriptRoot -ChildPath 'Reorder-BicepPropertyOrder.ps1'

        function Invoke-ReorderScript {
            param(
                [Parameter(Mandatory = $true)]
                [string]$Path,
                [switch]$Apply,
                [string[]]$Include
            )

            $arguments = @{ Path = $Path }
            if ($Apply) { $arguments.Apply = $true }
            if ($null -ne $Include -and $Include.Count -gt 0) { $arguments.Include = $Include }

            return (& $script:ScriptUnderTest @arguments *>&1 | Out-String)
        }

        function Assert-InOrder {
            param(
                [Parameter(Mandatory = $true)]
                [string]$Text,
                [Parameter(Mandatory = $true)]
                [string[]]$Needles
            )

            $lastIndex = -1
            foreach ($needle in $Needles) {
                $index = $Text.IndexOf($needle, [System.StringComparison]::Ordinal)
                $index | Should -BeGreaterThan $lastIndex
                $lastIndex = $index
            }
        }
    }

    BeforeEach {
        $script:TestRoot = Join-Path -Path $TestDrive -ChildPath ([System.Guid]::NewGuid().ToString('N'))
        New-Item -Path $script:TestRoot -ItemType Directory | Out-Null
    }

    AfterEach {
        # TestDrive automatically cleans up; explicit cleanup redundant
    }

    It 'does not change files in dry-run mode' {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        $original = @"
output result string = 'done'
var featureEnabled = true
param location string = 'westeurope'
metadata owner = 'nebula'
targetScope = 'subscription'
"@
        Set-Content -Path $file -Value $original -NoNewline

        $output = Invoke-ReorderScript -Path $script:TestRoot
        $current = Get-Content -Path $file -Raw

        $current | Should -Be $original
        $output | Should -Match 'Would update:'
        $output | Should -Match 'Run with -Apply to write changes.'
    }

    It 'reorders <Name>' -ForEach $reorderCases {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        Set-Content -Path $file -Value $Content -NoNewline

        Invoke-ReorderScript -Path $script:TestRoot -Apply | Out-Null
        $updated = Get-Content -Path $file -Raw

        Assert-InOrder -Text $updated -Needles $Needles
        foreach ($regex in $RegexAssertions) {
            $updated | Should -Match $regex
        }
    }

    It 'is idempotent after apply' {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        $content = @"
output out string = 'x'
var flag = true
param location string = 'westeurope'
targetScope = 'subscription'
"@
        Set-Content -Path $file -Value $content -NoNewline

        $firstApplyOutput = Invoke-ReorderScript -Path $script:TestRoot -Apply
        $secondApplyOutput = Invoke-ReorderScript -Path $script:TestRoot -Apply

        $firstApplyOutput | Should -Match 'Updated:'
        $secondApplyOutput | Should -Match 'Files updated: 0'
    }

    It 'reports no matching files when include filter excludes all bicep files' {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        Set-Content -Path $file -Value "targetScope = 'subscription'" -NoNewline

        $output = Invoke-ReorderScript -Path $script:TestRoot -Include @('*.nomatch')

        $output | Should -Match "No matching files found under"
    }

    It 'applies include filter and only updates selected files' {
        $includedFile = Join-Path -Path $script:TestRoot -ChildPath 'included.bicep'
        $excludedFile = Join-Path -Path $script:TestRoot -ChildPath 'excluded.bicep'

        $outOfOrder = @"
output out string = 'x'
param location string = 'westeurope'
targetScope = 'subscription'
"@

        Set-Content -Path $includedFile -Value $outOfOrder -NoNewline
        Set-Content -Path $excludedFile -Value $outOfOrder -NoNewline

        Invoke-ReorderScript -Path $script:TestRoot -Apply -Include @('included.bicep') | Out-Null

        $includedUpdated = Get-Content -Path $includedFile -Raw
        $excludedUpdated = Get-Content -Path $excludedFile -Raw

        Assert-InOrder -Text $includedUpdated -Needles @(
            "targetScope = 'subscription'",
            "param location string = 'westeurope'",
            "output out string = 'x'"
        )

        $excludedUpdated | Should -Be $outOfOrder
    }

    It 'preserves <Name> line endings on apply' -ForEach $lineEndingCases {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        $content = "output out string = 'x'$LineEnding" +
            "param location string = 'westeurope'$LineEnding" +
            "targetScope = 'subscription'$LineEnding"

        [System.IO.File]::WriteAllText($file, $content, [System.Text.UTF8Encoding]::new($false))

        Invoke-ReorderScript -Path $script:TestRoot -Apply | Out-Null

        $updated = [System.IO.File]::ReadAllText($file)
        $updated.Contains("targetScope = 'subscription'$LineEnding") | Should -BeTrue
        $updated.Contains("param location string = 'westeurope'$LineEnding") | Should -BeTrue
        $updated.Contains("output out string = 'x'$LineEnding") | Should -BeTrue
    }

    It 'preserves multiline triple-quoted decorators and trailing declarations on apply' {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        $content = @'
import { generateDeploymentName } from '../../Common/bicep/utilities.bicep'

targetScope = 'subscription'

param resourceGroupName string

@description('''
        The tag object.
        For example (in YAML):
            ApplicationID: 1234
            PipelineBuildNumber: 2022.08.02-main
''')
param tags object = {}

@onlyIfNotExists()
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
    name: resourceGroupName
    location: deployment().location
    tags: tags
}

module resources 'resources.bicep' = {
    scope: az.subscription()
    name: generateDeploymentName('resources')
    params: {
        resourceGroupName: resourceGroupName
        tags: tags
    }
    dependsOn: [
        resourceGroup
    ]
}
'@

        Set-Content -Path $file -Value $content -NoNewline

        Invoke-ReorderScript -Path $script:TestRoot -Apply | Out-Null
        $updated = Get-Content -Path $file -Raw

        $updated | Should -Be $content
        $updated | Should -Match "@description\('''\r?\n\s+The tag object\."
        $updated | Should -Match "resource resourceGroup 'Microsoft\.Resources/resourceGroups@2025-04-01' = \{"
        $updated | Should -Match "module resources 'resources\.bicep' = \{"
    }

    It 'preserves nested array and for-expression module bodies while reordering declarations' {
        $file = Join-Path -Path $script:TestRoot -ChildPath 'main.bicep'
        $content = @'
output itemCount int = length(items)
module child './child.bicep' = [
    for item in items: {
        params: {
            location: location
        }
        name: 'child-${item}'
    }
]
var items = [
    'a'
    'b'
]
param location string = 'westeurope'
targetScope = 'resourceGroup'
'@

        Set-Content -Path $file -Value $content -NoNewline

        Invoke-ReorderScript -Path $script:TestRoot -Apply | Out-Null
        $updated = Get-Content -Path $file -Raw

        Assert-InOrder -Text $updated -Needles @(
            "targetScope = 'resourceGroup'",
            "param location string = 'westeurope'",
            "var items = [",
            "module child './child.bicep' = [",
            "output itemCount int = length(items)"
        )

        $updated | Should -Match "targetScope = 'resourceGroup'\r?\nparam location string = 'westeurope'"
        $updated | Should -Match "var items = \[\r?\n\s+'a'\r?\n\s+'b'\r?\n\]"
        $updated | Should -Match "module child '\./child\.bicep' = \[\r?\n\s+for item in items: \{"
        $updated | Should -Match "\s+name: 'child-\$\{item\}'\r?\n\s+params: \{\r?\n\s+location: location\r?\n\s+\}"
    }
}
