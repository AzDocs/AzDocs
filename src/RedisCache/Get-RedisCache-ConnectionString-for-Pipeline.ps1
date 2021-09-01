[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $RedisInstanceName,
    [Parameter(Mandatory)][string] $RedisInstanceResourceGroupName,
    [Parameter()][switch] $ForceUseInsecureNonSslConnection,
    [Parameter()][string] $OutputPipelineVariableName = "RedisConnectionString"
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

$redisKey = (Invoke-Executable az redis list-keys --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName | ConvertFrom-Json).primaryKey
$redis = Invoke-Executable az redis show --name $RedisInstanceName --resource-group $RedisInstanceResourceGroupName | ConvertFrom-Json

$port = $redis.sslPort
$useSsl = $true

if ($ForceUseInsecureNonSslConnection)
{
    Write-Warning "You are using the non-ssl connection for RedisCache. We strongly recommend using the SSL version instead."
    if ($redis.enableNonSslPort -eq $false)
    {
        $message = "You are trying to use the non-SSL port for RedisCache, but this port isn't available. Please enable the non-SSL port before using it."
        Write-Host "##vso[task.complete result=Failed;]$message"
        throw $message
    }

    $port = $redis.port
    $useSsl = $false
}

$redisConnectionString = "$($RedisInstanceName).redis.cache.windows.net:$($port),password=$($redisKey),ssl=$($useSsl),abortConnect=False"
Write-Host "redisConnectionString: $redisConnectionString"
Write-Host "##vso[task.setvariable variable=$($OutputPipelineVariableName);isOutput=true]$redisConnectionString"

Write-Footer -ScopedPSCmdlet $PSCmdlet