#requires -Version 7.4

<#
.SYNOPSIS
Reorders top-level declarations and resource/module body properties in Bicep files.

.DESCRIPTION
By default, this script runs in dry-run mode and reports which files would change.
Use -Apply to write the reordered content back to disk.

.EXAMPLE
./Nebula/tools/Reorder-BicepPropertyOrder.ps1 -Path ./Nebula
Runs a dry run across all .bicep files under ./Nebula.

.EXAMPLE
./Nebula/tools/Reorder-BicepPropertyOrder.ps1 -Path ./Nebula -Apply
Applies the reordering changes to files.

.EXAMPLE
./Nebula/tools/Reorder-BicepPropertyOrder.ps1 -Path ./Nebula/platform-provisioning -Include "*.bicep", "*.bicepparam"
Runs on a specific folder and file patterns.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Path = "Nebula",

    [Parameter()]
    [switch]$Apply,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string[]]$Include = @("*.bicep")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:LineWithEndingRegex = [System.Text.RegularExpressions.Regex]::new('.*(?:\r\n|\n|$)', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:TopLevelKeywordRegex = [System.Text.RegularExpressions.Regex]::new('^(targetScope|metadata|param|func|var|resource|module|output)\b', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:PropertyRegex = [System.Text.RegularExpressions.Regex]::new('^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:InnerResourceRegex = [System.Text.RegularExpressions.Regex]::new('^\s*resource\s+', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:DecoratorRegex = [System.Text.RegularExpressions.Regex]::new('^@', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:ExistingResourceRegex = [System.Text.RegularExpressions.Regex]::new('\bexisting\b', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$script:PreferredFileOrder = @('targetScope', 'metadata', 'param', 'var', 'func', 'resource_existing', 'deployable', 'output')
$script:PreferredModuleBodyOrder = @('scope', 'name', 'params')
$script:PreferredResourceBodyOrder = @('parent', 'scope', 'name', 'location', 'extendedLocation', 'zones', 'sku', 'kind', 'scale', 'plan', 'identity', 'dependsOn', 'tags', 'properties')

function Get-LineEnding {
    param([string]$Text)

    if ($Text.Contains("`r`n")) {
        return "`r`n"
    }

    return "`n"
}

function Get-ParsingMaskText {
    param([string]$Text)

    $sb = [System.Text.StringBuilder]::new($Text.Length)
    $inString = $false
    $inMultilineString = $false
    $inBlockComment = $false
    $inLineComment = $false

    for ($i = 0; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        $next = if ($i + 1 -lt $Text.Length) { $Text[$i + 1] } else { [char]0 }
        $next2 = if ($i + 2 -lt $Text.Length) { $Text[$i + 2] } else { [char]0 }

        if ($inLineComment) {
            if ($c -eq "`r" -or $c -eq "`n") {
                $inLineComment = $false
                [void]$sb.Append($c)
            }
            else {
                [void]$sb.Append(' ')
            }
            continue
        }

        if ($inBlockComment) {
            if ($c -eq '*' -and $next -eq '/') {
                [void]$sb.Append(' ')
                [void]$sb.Append(' ')
                $inBlockComment = $false
                $i++
                continue
            }

            if ($c -eq "`r" -or $c -eq "`n") {
                [void]$sb.Append($c)
            }
            else {
                [void]$sb.Append(' ')
            }
            continue
        }

        if ($inMultilineString) {
            if ($c -eq "'" -and $next -eq "'" -and $next2 -eq "'") {
                [void]$sb.Append(' ')
                [void]$sb.Append(' ')
                [void]$sb.Append(' ')
                $inMultilineString = $false
                $i += 2
                continue
            }

            if ($c -eq "`r" -or $c -eq "`n") {
                [void]$sb.Append($c)
            }
            else {
                [void]$sb.Append(' ')
            }
            continue
        }

        if ($inString) {
            if ($c -eq "'") {
                if ($next -eq "'") {
                    [void]$sb.Append(' ')
                    [void]$sb.Append(' ')
                    $i++
                    continue
                }

                $inString = $false
                [void]$sb.Append(' ')
                continue
            }

            if ($c -eq "`r" -or $c -eq "`n") {
                [void]$sb.Append($c)
            }
            else {
                [void]$sb.Append(' ')
            }
            continue
        }

        if ($c -eq '/' -and $next -eq '/') {
            [void]$sb.Append(' ')
            [void]$sb.Append(' ')
            $inLineComment = $true
            $i++
            continue
        }

        if ($c -eq '/' -and $next -eq '*') {
            [void]$sb.Append(' ')
            [void]$sb.Append(' ')
            $inBlockComment = $true
            $i++
            continue
        }

        if ($c -eq "'" -and $next -eq "'" -and $next2 -eq "'") {
            [void]$sb.Append(' ')
            [void]$sb.Append(' ')
            [void]$sb.Append(' ')
            $inMultilineString = $true
            $i += 2
            continue
        }

        if ($c -eq "'") {
            [void]$sb.Append(' ')
            $inString = $true
            continue
        }

        [void]$sb.Append($c)
    }

    return $sb.ToString()
}

function Get-LinesWithEndings {
    param([string]$Text)

    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($match in $script:LineWithEndingRegex.Matches($Text)) {
        if ($match.Value.Length -gt 0) {
            $lines.Add($match.Value)
        }
    }

    return $lines
}

function Get-BraceDepthDelta {
    param([string]$CodeOnly)

    $delta = 0
    for ($i = 0; $i -lt $CodeOnly.Length; $i++) {
        $ch = $CodeOnly[$i]
        if ($ch -eq '{' -or $ch -eq '[') {
            $delta++
        }
        elseif ($ch -eq '}' -or $ch -eq ']') {
            $delta--
        }
    }

    return $delta
}

function Get-OrderedSegments {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IEnumerable]$Segments,
        [Parameter(Mandatory = $true)]
        [string[]]$PreferredOrder,
        [Parameter(Mandatory = $true)]
        [string]$NameProperty
    )

    $segmentList = [System.Collections.Generic.List[object]]::new()
    foreach ($segment in $Segments) {
        $segmentList.Add($segment)
    }

    $used = [System.Collections.Generic.HashSet[int]]::new()
    $ordered = [System.Collections.Generic.List[object]]::new()

    foreach ($name in $PreferredOrder) {
        for ($i = 0; $i -lt $segmentList.Count; $i++) {
            if ($used.Contains($i)) {
                continue
            }

            if ($segmentList[$i].$NameProperty -eq $name) {
                [void]$used.Add($i)
                [void]$ordered.Add($segmentList[$i])
            }
        }
    }

    for ($i = 0; $i -lt $segmentList.Count; $i++) {
        if (-not $used.Contains($i)) {
            [void]$ordered.Add($segmentList[$i])
        }
    }

    return $ordered
}

function Add-BodySegment {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Segments,
        [Parameter(Mandatory = $true)]
        [ref]$CurrentName,
        [Parameter(Mandatory = $true)]
        [ref]$CurrentText
    )

    if ($null -eq $CurrentName.Value) {
        return
    }

    $Segments.Add([pscustomobject]@{
            Name = $CurrentName.Value
            Text = $CurrentText.Value.ToString()
        })

    $CurrentName.Value = $null
    $CurrentText.Value = [System.Text.StringBuilder]::new()
}

function Find-NextOpeningBrace {
    param(
        [string]$Text,
        [int]$StartIndex
    )

    $maskedText = Get-ParsingMaskText -Text $Text

    for ($i = $StartIndex; $i -lt $maskedText.Length; $i++) {
        if ($maskedText[$i] -eq '{') {
            return $i
        }
    }

    return -1
}

function Find-MatchingBrace {
    param(
        [string]$Text,
        [int]$OpenBraceIndex
    )

    $maskedText = Get-ParsingMaskText -Text $Text
    $depth = 0

    for ($i = $OpenBraceIndex; $i -lt $maskedText.Length; $i++) {
        $c = $maskedText[$i]

        if ($c -eq '{') {
            $depth++
        }
        elseif ($c -eq '}') {
            $depth--
            if ($depth -eq 0) {
                return $i
            }
        }
    }

    return -1
}

function Get-BicepFileDeclarations {
    param([string]$Text)

    $lines = Get-LinesWithEndings -Text $Text
    $maskedLines = Get-LinesWithEndings -Text (Get-ParsingMaskText -Text $Text)

    $depth = 0
    $declarations = [System.Collections.Generic.List[object]]::new()
    $pendingLines = [System.Text.StringBuilder]::new()
    $currentType = $null
    $currentText = [System.Text.StringBuilder]::new()
    $headerText = [System.Text.StringBuilder]::new()
    $inDeclaration = $false
    $inPreamble = $false

    for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
        $line = $lines[$lineIndex]
        $maskedLine = $maskedLines[$lineIndex]
        $trimmed = $maskedLine.TrimEnd("`r", "`n").Trim()

        if (-not $inDeclaration) {
            $isBlank = ($trimmed -eq '')
            $isDecorator = $script:DecoratorRegex.IsMatch($trimmed)
            $keywordMatch = $script:TopLevelKeywordRegex.Match($trimmed)

            if ($isBlank) {
                [void]$pendingLines.Append($line)
            }
            elseif ($isDecorator) {
                $inPreamble = $true
                [void]$pendingLines.Append($line)
            }
            elseif ($keywordMatch.Success) {
                $keyword = $keywordMatch.Groups[1].Value
                $type = $keyword
                if ($keyword -eq 'resource') {
                    if ($script:ExistingResourceRegex.IsMatch($trimmed)) {
                        $type = 'resource_existing'
                    }
                    else {
                        $type = 'deployable'
                    }
                }
                elseif ($keyword -eq 'module') {
                    $type = 'deployable'
                }

                if ($declarations.Count -eq 0 -and -not $inPreamble) {
                    [void]$headerText.Append($pendingLines.ToString())
                    $pendingLines = [System.Text.StringBuilder]::new()
                }

                $currentType = $type
                [void]$currentText.Append($pendingLines.ToString())
                $pendingLines = [System.Text.StringBuilder]::new()
                $inPreamble = $false
                [void]$currentText.Append($line)
                $inDeclaration = $true
            }
            else {
                if ($declarations.Count -eq 0 -and -not $inPreamble) {
                    [void]$headerText.Append($pendingLines.ToString())
                    $pendingLines = [System.Text.StringBuilder]::new()
                    [void]$headerText.Append($line)
                }
                else {
                    [void]$pendingLines.Append($line)
                }
            }
        }
        else {
            [void]$currentText.Append($line)
        }

        $depth += Get-BraceDepthDelta -CodeOnly $maskedLine

        if ($inDeclaration -and $depth -eq 0) {
            $declarations.Add([pscustomobject]@{
                    Type = $currentType
                    Text = $currentText.ToString()
                })
            $currentText = [System.Text.StringBuilder]::new()
            $currentType = $null
            $inDeclaration = $false
        }
    }

    return [pscustomobject]@{
        Header       = $headerText.ToString()
        Declarations = $declarations
        Trailing     = $pendingLines.ToString()
    }
}

function Test-FileNameIncluded {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [Parameter(Mandatory = $true)]
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($FileName -like $pattern) {
            return $true
        }
    }

    return $false
}

function Get-FilteredBicepFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,
        [Parameter(Mandatory = $true)]
        [string[]]$Patterns
    )

    @(Get-ChildItem -LiteralPath $RootPath -Recurse -File |
        Where-Object { Test-FileNameIncluded -FileName $_.Name -Patterns $Patterns } |
        Sort-Object -Property FullName)
}

function Reorder-FileDeclarations {
    param([string]$Text)

    $parsed = Get-BicepFileDeclarations -Text $Text
    $declarations = $parsed.Declarations

    if ($declarations.Count -le 1) {
        return [pscustomobject]@{
            Text    = $Text
            Changed = $false
        }
    }

    $ordered = Get-OrderedSegments -Segments $declarations -PreferredOrder $script:PreferredFileOrder -NameProperty 'Type'
    $lineEnding = Get-LineEnding -Text $Text

    # Ensure proper line endings between declarations
    $normalizedOrdered = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $ordered.Count; $i++) {
        $declText = $ordered[$i].Text
        $isLastDeclaration = ($i -eq $ordered.Count - 1)
        
        if (-not $isLastDeclaration -and -not $declText.EndsWith("`r`n") -and -not $declText.EndsWith("`n")) {
            $declText = $declText + $lineEnding
        }
        
        [void]$normalizedOrdered.Add([pscustomobject]@{
            Type = $ordered[$i].Type
            Text = $declText
        })
    }

    $rebuilt = [System.Text.StringBuilder]::new()
    [void]$rebuilt.Append($parsed.Header)
    
    foreach ($decl in $normalizedOrdered) {
        [void]$rebuilt.Append($decl.Text)
    }
    
    [void]$rebuilt.Append($parsed.Trailing)

    $newText = $rebuilt.ToString()
    return [pscustomobject]@{
        Text    = $newText
        Changed = ($newText -ne $Text)
    }
}

function Reorder-DeclarationBody {
    param(
        [string]$Body,
        [ValidateSet('module', 'resource')]
        [string]$Kind
    )

    $preferredOrder = if ($Kind -eq 'module') { $script:PreferredModuleBodyOrder } else { $script:PreferredResourceBodyOrder }

    $lines = Get-LinesWithEndings -Text $Body
    $maskedLines = Get-LinesWithEndings -Text (Get-ParsingMaskText -Text $Body)

    $depth = 0
    $preamble = [System.Text.StringBuilder]::new()
    $segments = [System.Collections.Generic.List[object]]::new()
    $currentName = $null
    $currentText = [System.Text.StringBuilder]::new()

    for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
        $line = $lines[$lineIndex]
        $maskedLine = $maskedLines[$lineIndex]

        if ($depth -eq 0) {
            $propertyMatch = $script:PropertyRegex.Match($maskedLine)
            $innerResourceMatch = $script:InnerResourceRegex.Match($maskedLine)
            if ($propertyMatch.Success) {
                Add-BodySegment -Segments $segments -CurrentName ([ref]$currentName) -CurrentText ([ref]$currentText)
                $currentName = $propertyMatch.Groups[1].Value
                [void]$currentText.Append($line)
            }
            elseif ($innerResourceMatch.Success) {
                Add-BodySegment -Segments $segments -CurrentName ([ref]$currentName) -CurrentText ([ref]$currentText)
                $currentName = '__innerResource__'
                [void]$currentText.Append($line)
            }
            else {
                if ($null -ne $currentName) {
                    [void]$currentText.Append($line)
                }
                else {
                    [void]$preamble.Append($line)
                }
            }
        }
        else {
            if ($null -ne $currentName) {
                [void]$currentText.Append($line)
            }
            else {
                [void]$preamble.Append($line)
            }
        }

        $depth += Get-BraceDepthDelta -CodeOnly $maskedLine
    }

    Add-BodySegment -Segments $segments -CurrentName ([ref]$currentName) -CurrentText ([ref]$currentText)

    if ($segments.Count -eq 0) {
        return [pscustomobject]@{
            Body    = $Body
            Changed = $false
        }
    }

    $ordered = Get-OrderedSegments -Segments $segments -PreferredOrder $preferredOrder -NameProperty 'Name'

    $rebuilt = [System.Text.StringBuilder]::new()
    [void]$rebuilt.Append($preamble.ToString())
    foreach ($segment in $ordered) {
        [void]$rebuilt.Append($segment.Text)
    }

    $newBody = $rebuilt.ToString()

    return [pscustomobject]@{
        Body    = $newBody
        Changed = ($newBody -ne $Body)
    }
}

function Process-BicepText {
    param([string]$Text)

    $working = $Text
    $reorderedDeclarations = 0

    $fileResult = Reorder-FileDeclarations -Text $working
    if ($fileResult.Changed) {
        $working = $fileResult.Text
        $reorderedDeclarations++
    }

    $parsed = Get-BicepFileDeclarations -Text $working
    $declarationUpdated = $false

    for ($i = 0; $i -lt $parsed.Declarations.Count; $i++) {
        $decl = $parsed.Declarations[$i]
        $kind = if ($decl.Type -eq 'deployable' -and $decl.Text -match '^\s*(?:@[A-Za-z_][A-Za-z0-9_]*\([^\r\n]*\)\s*)*module\b') {
            'module'
        }
        elseif ($decl.Type -eq 'deployable' -or $decl.Type -eq 'resource_existing') {
            'resource'
        }
        else {
            $null
        }

        if ($null -eq $kind) {
            continue
        }

        $openBrace = Find-NextOpeningBrace -Text $decl.Text -StartIndex 0
        if ($openBrace -lt 0) {
            continue
        }

        $closeBrace = Find-MatchingBrace -Text $decl.Text -OpenBraceIndex $openBrace
        if ($closeBrace -lt 0) {
            continue
        }

        $bodyStart = $openBrace + 1
        $bodyLength = $closeBrace - $bodyStart
        $body = if ($bodyLength -gt 0) { $decl.Text.Substring($bodyStart, $bodyLength) } else { '' }

        $reorderResult = Reorder-DeclarationBody -Body $body -Kind $kind
        if ($reorderResult.Changed) {
            $declTextUpdated = $decl.Text.Remove($bodyStart, $bodyLength).Insert($bodyStart, $reorderResult.Body)
            $parsed.Declarations[$i] = [pscustomobject]@{
                Type = $decl.Type
                Text = $declTextUpdated
            }
            $declarationUpdated = $true
            $reorderedDeclarations++
        }
    }

    if ($declarationUpdated) {
        $rebuilt = [System.Text.StringBuilder]::new()
        [void]$rebuilt.Append($parsed.Header)
        foreach ($decl in $parsed.Declarations) {
            [void]$rebuilt.Append($decl.Text)
        }
        [void]$rebuilt.Append($parsed.Trailing)
        $working = $rebuilt.ToString()
    }

    return [pscustomobject]@{
        Text                  = $working
        Changed               = ($working -ne $Text)
        ReorderedDeclarations = $reorderedDeclarations
    }
}

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Path '$Path' was not found or is not a directory."
}

$allFiles = @(Get-FilteredBicepFiles -RootPath $Path -Patterns $Include)

if ($allFiles.Count -eq 0) {
    Write-Host "No matching files found under '$Path'."
    exit 0
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$totalChangedFiles = 0
$totalReorderedDeclarations = 0

foreach ($file in $allFiles) {
    $original = [System.IO.File]::ReadAllText($file.FullName)
    $lineEnding = Get-LineEnding -Text $original

    $result = Process-BicepText -Text $original
    if (-not $result.Changed) {
        continue
    }

    $outputText = $result.Text
    if ($lineEnding -eq "`r`n") {
        $outputText = $outputText -replace "(?<!`r)`n", "`r`n"
    }

    if ($Apply) {
        [System.IO.File]::WriteAllText($file.FullName, $outputText, $utf8NoBom)
        Write-Host "Updated: $($file.FullName) (reordered declarations: $($result.ReorderedDeclarations))"
    }
    else {
        Write-Host "Would update: $($file.FullName) (reordered declarations: $($result.ReorderedDeclarations))"
    }

    $totalChangedFiles++
    $totalReorderedDeclarations += $result.ReorderedDeclarations
}

if ($Apply) {
    Write-Host "Done. Files updated: $totalChangedFiles. Declarations reordered: $totalReorderedDeclarations."
}
else {
    Write-Host "Dry run complete. Files that would be updated: $totalChangedFiles. Declarations to reorder: $totalReorderedDeclarations."
    Write-Host "Run with -Apply to write changes."
}
