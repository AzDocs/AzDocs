function Write-Header {
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-Host "> $($myInvocation.InvocationName)"  -ForegroundColor Green

    [System.Management.Automation.PSCmdlet]$headerCmdlet = Get-Variable -Name "PSCmdlet" -Scope 1 -ValueOnly

    if ($headerCmdlet.ParameterSetName -ne '__AllParameterSets') {
        Write-Host ">  ParameterSetName : $($headerCmdlet.ParameterSetName)"  -ForegroundColor DarkGray
    }

    $myInvocation.BoundParameters.Keys | ForEach-Object {
        $kv = $myInvocation.BoundParameters[$_]
        Write-Host ">  $_ : $kv"  -ForegroundColor DarkGray
    }
}

function Write-Footer {
    [System.Management.Automation.InvocationInfo]$myInvocation = Get-Variable -Name "MyInvocation" -Scope 1 -ValueOnly
    Write-Host "< $($myInvocation.InvocationName)"  -ForegroundColor Green
}
