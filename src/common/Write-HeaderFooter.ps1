function Write-ColorHost {
    [CmdletBinding()]
    param (
        [Parameter()][string] $Message,
        [Alias("Type")]
        [Parameter()][ValidateSet('White', 'Orange', 'Green', 'Blue', 'Purple', 'Red')][string] $Color = 'White',
        [Parameter()][switch] $NoNewLine
    )

    if ($Color -eq 'White') {
        Write-Host $Message -NoNewline:$NoNewLine
    }

    if (Test-Path env:SYSTEM_HOSTTYPE) { # Are we in Azure DevOps?
        switch ($Color) {
            'Orange' {
                $formatPrefix = '##[warning]'
            }
            'Green' {
                $formatPrefix = '##[section]'
            }
            'Blue' {
                $formatPrefix = '##[command]'
            }
            'Purple' {
                $formatPrefix = '##[debug]'
            }
            'Red' {
                $formatPrefix = '##[error]'
            }
            Default {}
        }
        Write-Host "$formatPrefix$Message" -NoNewline:$NoNewLine
    }
    else {
        switch -wildcard ($Color) {
            'Orange' {
                $Color = "Yellow"
            }
            'Blue' {
                $Color = "Cyan"
            }
            'Purple' {
                $Color = "Magenta"
            }
            Default {}
        }
        Write-Host $Message -ForegroundColor $Color -NoNewline:$NoNewLine
    }
}

function Write-Header {
    [CmdletBinding()]
    param (
        [Parameter()][string] $OverrideMessage,
        [Parameter()][switch] $OmitOutputParameters
    )
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-ColorHost "> $($myInvocation.InvocationName) $OverrideMessage" -Color Orange
    if ($OmitOutputParameters) {
        return
    }

    [System.Management.Automation.PSCmdlet]$headerCmdlet = Get-Variable -Name "PSCmdlet" -Scope 1 -ValueOnly
    if ($headerCmdlet.ParameterSetName -ne '__AllParameterSets') {
        Write-ColorHost ">  ParameterSetName : $($headerCmdlet.ParameterSetName)" -Color Green
    }

    $myInvocation.BoundParameters.Keys | ForEach-Object {
        $key = $_
        $value = $myInvocation.BoundParameters[$key]
        If ($key -like '*password*') {
            $value = '****'
        }
        Write-ColorHost ">  $key : $value" -Color Green
    }
}

function Write-Footer {
    [System.Management.Automation.InvocationInfo] $myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-ColorHost "< $($myInvocation.InvocationName)" -Color Orange
}