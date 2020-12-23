function Write-ColorHost {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Message,

        [Parameter()]
        [validateset('Regular', 'BeginGroup', 'EndGroup', 'Background')]
        [string]
        $Type = 'Regular',

        [Parameter()]
        [switch]
        $NoNewLine
    )

    if ($Type -eq 'Regular') {
        Write-Host $Message -NoNewline:$NoNewLine
    }

    if (Test-Path env:System_HostType) {
        switch ($Type) {
            'BeginGroup' {
                if ($env:System_HostType -eq 'build') {
                    $formatPrefix = '##[group]'
                }
                else {
                    $formatPrefix = '##[warning]'
                }
                Write-Host "$formatPrefix$Message" -NoNewline:$NoNewLine
            }
            'EndGroup' {
                if ($env:System_HostType -eq 'build') {
                    $formatPrefix = '##[endgroup]'
                }
                else {
                    $formatPrefix = '##[warning]'
                }
                Write-Host "$formatPrefix$Message" -NoNewline:$NoNewLine
            }
            'Background' {
                Write-Host "##[section]$Message" -NoNewline:$NoNewLine
            }
            Default {}
        }
    }
    else {
        switch -wildcard ($Type) {
            '*Group' {
                Write-Host $Message -ForegroundColor Green  -NoNewline:$NoNewLine
            }
            'Background' {
                Write-Host $Message  -ForegroundColor DarkGray  -NoNewline:$NoNewLine
            }
            Default {}
        }
    }
}

function Write-Header {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $OverrideHeaderText,

        [Parameter()]
        [switch]
        $HideParameters
    )
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-ColorHost "> $($myInvocation.InvocationName) $OverrideHeaderText" -Type 'BeginGroup'
    if ($HideParameters) {
        return
    }

    [System.Management.Automation.PSCmdlet]$headerCmdlet = Get-Variable -Name "PSCmdlet" -Scope 1 -ValueOnly
    if ($headerCmdlet.ParameterSetName -ne '__AllParameterSets') {
        Write-ColorHost ">  ParameterSetName : $($headerCmdlet.ParameterSetName)" -Type 'Background'
    }

    $myInvocation.BoundParameters.Keys | ForEach-Object {
        $key = $_
        $value = $myInvocation.BoundParameters[$key]
        If ($key -like '*password*') {
            $value = '****'
        }
        Write-ColorHost ">  $key : $value" -Type 'Background'
    }
}

function Write-Footer {
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-ColorHost "< $($myInvocation.InvocationName)" -Type 'EndGroup'
}