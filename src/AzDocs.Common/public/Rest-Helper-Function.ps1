function Invoke-AzRestCall
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][ValidateSet('DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT')][string] $Method,
        [Parameter()][string] $ResourceId,
        [Parameter()][string] $ResourceUrl,
        [Parameter(Mandatory)][string] $ApiVersion, # Example: "2021-02-01-preview"
        [Parameter(Mandatory)][PSCustomObject] $Body
    )

    $json = ($Body | ConvertTo-Json -Compress -Depth 100).Replace("""", """""")

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
        $url = "$($ResourceId)api-version=$($ApiVersion)"
    }

    Invoke-Executable az rest --method $Method --url $url --body """$json"""
}
