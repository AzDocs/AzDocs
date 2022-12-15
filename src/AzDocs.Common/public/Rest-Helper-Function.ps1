function Invoke-AzRestCall
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][ValidateSet('DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT')][string] $Method,
        [Parameter()][string] $ResourceId,
        [Parameter()][string] $ResourceUrl,
        [Parameter(Mandatory)][string] $ApiVersion, # Example: "2021-02-01-preview"
        [Parameter()][PSCustomObject] $Body,
        [Parameter()][switch] $AllowToFail
    )

    if (!$ResourceUrl -and !$ResourceId)
    {
        throw 'Please specify URL or ResourceId to send the request to.'
    }

    $url = $null
    if ($ResourceUrl)
    {
        $url = "$($ResourceUrl)?api-version=$($ApiVersion)"
    }
    
    if ($ResourceId)
    {
        $url = "$($ResourceId)?api-version=$($ApiVersion)"
    }
    
    if (!$Body)
    {
        Invoke-Executable -AllowToFail:$AllowToFail az rest --method $Method --url $url 
    }
    else
    {
        $json = ($Body | ConvertTo-Json -Compress -Depth 100).Replace("""", """""")
        Invoke-Executable -AllowToFail:$AllowToFail az rest --method $Method --url $url --body """$json"""
    }
}

function Show-RestError
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][PSObject] $Exception
    )

    Write-Host 'Response: ' $Exception -ForegroundColor Red
    Write-Host 'StatusCode:' $Exception.Exception.Response.StatusCode.value__ -ForegroundColor Red
    Write-Host 'Reason:' $Exception.Exception.Response.ReasonPhrase -ForegroundColor Red
    if ($Exception.Exception.Response.StatusDescription)
    {
        Write-Host 'StatusDescription:' $Exception.Exception.Response.StatusDescription -ForegroundColor Red
    }
    Write-Host 'Exception:' $Exception.Exception -ForegroundColor Red
    throw $Exception;
}
