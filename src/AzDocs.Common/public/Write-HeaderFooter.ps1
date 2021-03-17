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
                $PSColor = "Yellow"
            }
            'Blue' {
                $PSColor = "Cyan"
            }
            'Purple' {
                $PSColor = "Magenta"
            }
            Default {
                $PSColor = $Color
            }
        }
        Write-Host $Message -ForegroundColor $PSColor -NoNewline:$NoNewLine
    }
}

function Write-Header {
    [CmdletBinding()]
    param (
        [Parameter()][string] $OverrideMessage,
        [Parameter()][switch] $OmitOutputParameters,
        [Parameter()][System.Management.Automation.PSCmdlet] $ScopedPSCmdlet
    )
    
    Write-ColorHost "> $($ScopedPSCmdlet.MyInvocation.InvocationName) $OverrideMessage" -Color Orange
    if ($OmitOutputParameters) {
        return
    }

    if ($ScopedPSCmdlet.ParameterSetName -ne '__AllParameterSets') {
        Write-ColorHost ">  ParameterSetName : $($ScopedPSCmdlet.ParameterSetName)" -Color Green
    }

    $ScopedPSCmdlet.MyInvocation.BoundParameters.Keys | ForEach-Object {
        $key = $_
        $value = $ScopedPSCmdlet.MyInvocation.BoundParameters[$key]
        If ($key -like '*password*') {
            $value = '****'
        }
        Write-ColorHost ">  $key : $value" -Color Green
    }
}

function Write-Footer {
    [CmdletBinding()]
    param (
        [Parameter()][System.Management.Automation.PSCmdlet] $ScopedPSCmdlet
    )

    Write-ColorHost "< $($ScopedPSCmdlet.MyInvocation.InvocationName)" -Color Orange
}