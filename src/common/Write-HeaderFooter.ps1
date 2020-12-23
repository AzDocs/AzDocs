function Write-ColorHost {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Message,

        [Parameter()]
        [validateset('Regular', 'BeginGroup', 'EndGroup', 'Background')]
        [string]
        $Type = 'Regular'
    )
    if ( $Type -eq 'Regular') {
        Write-Host $Message
    }

    if ($env:System_HostType) {
        switch ($Type) {
            'BeginGroup' {
                Write-Host "##[group]> $Message"
            }
            'EndGroup' {
                Write-Host "##[endgroup]> $Message"
            }
            'Background' {
                Write-Host "##[section]> $Message"
            }
            Default {}
        }
    }
    else {

        switch -wildcard ($Type) {
            '*Group' {
                Write-Host $Message -ForegroundColor Green
            }
            'Background' {
                Write-Host $Message  -ForegroundColor DarkGray
            }
            Default {}
        }
    }
}

function Write-Header {
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-ColorHost "> $($myInvocation.InvocationName)" -Type 'BeginGroup'

    [System.Management.Automation.PSCmdlet]$headerCmdlet = Get-Variable -Name "PSCmdlet" -Scope 1 -ValueOnly

    if ($headerCmdlet.ParameterSetName -ne '__AllParameterSets') {
        Write-ColorHost ">  ParameterSetName : $($headerCmdlet.ParameterSetName)" -Type 'Background'
    }

    $myInvocation.BoundParameters.Keys | ForEach-Object {
        $kv = $myInvocation.BoundParameters[$_]
        Write-ColorHost ">  $_ : $kv" -Type 'Background'
    }
}

function Write-Footer {
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-ColorHost "< $($myInvocation.InvocationName)" -Type 'EndGroup'
}