function Invoke-AzRestCall
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][ValidateSet('DELETE', 'GET', 'HEAD', 'OPTIONS', 'PATCH', 'POST', 'PUT')][string] $Method,
        [Parameter(Mandatory)][string] $ResourceId,
        [Parameter(Mandatory)][string] $ApiVersion, # Example: "2021-02-01-preview"
        [Parameter(Mandatory)][PSCustomObject] $Body
    )

    $json = ($Body | ConvertTo-Json -Compress -Depth 100).Replace("""", """""")
    Invoke-Executable az rest --method $Method --url "$($ResourceId)?api-version=$($ApiVersion)" --body """$json"""
}
