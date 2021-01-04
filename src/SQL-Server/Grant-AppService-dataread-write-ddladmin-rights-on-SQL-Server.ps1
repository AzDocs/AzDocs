[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $sqlServerResourceGroupName,

    [Parameter(Mandatory)]
    [String] $sqlServerName,

    [Parameter(Mandatory)]
    [String] $sqlDatabaseName,

    [Parameter(Mandatory)]
    [String] $serviceUserEmail,

    [Parameter(Mandatory)]
    [String] $serviceUserObjectId,

    [Parameter(Mandatory)]
    [String] $serviceUserPassword,

    [Parameter(Mandatory)]
    [String] $appServiceName,

    [Parameter()]
    [String] $appServiceSlotName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az sql server ad-admin create --resource-group $sqlServerResourceGroupName --server-name $sqlServerName --display-name $serviceUserEmail --object-id $serviceUserObjectId

$altIdProfilePath = Join-Path ([io.path]::GetTempPath()) '.azure-altId'
$AccessToken = $null
try {
    $env:AZURE_CONFIG_DIR = $altIdProfilePath

    Invoke-Executable az login --username $serviceUserEmail --password $serviceUserPassword --allow-no-subscriptions
    $AccessToken = (Invoke-Executable az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
}
finally {
    $env:AZURE_CONFIG_DIR = $null
    Remove-Item -Recurse -Force $altIdProfilePath
}
if(!$AccessToken){
    throw 'Could not fetch access token, something went wrong.'
}

$appServicePrincipalName = $appServiceName
if ($appServiceSlotName) {
    $appServicePrincipalName += "/slots/$appServiceSlotName"
}

Write-Host "Opening database connection for ensuring the managed identity of $appServicePrincipalName"

$sql = @"
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = '$appServicePrincipalName')
    BEGIN
        CREATE USER [$appServicePrincipalName] FROM EXTERNAL PROVIDER;
        ALTER ROLE db_datareader ADD MEMBER [$appServicePrincipalName];
        ALTER ROLE db_datawriter ADD MEMBER [$appServicePrincipalName];
        ALTER ROLE db_ddladmin ADD MEMBER [$appServicePrincipalName];
    END
"@

$conn = [System.Data.SqlClient.SqlConnection]::new()
try {
    $conn.ConnectionString = "Server=tcp:$($sqlServerName).database.windows.net,1433;Initial Catalog=$($sqlDatabaseName);Persist Security Info=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    $conn.AccessToken = $AccessToken
    $conn.Open()
    $cmd = [System.Data.SqlClient.SqlCommand]::new($sql, $conn);
    if ($cmd.ExecuteNonQuery() -ne -1) {
        Write-Host "Failed to add the managed identity for $appServicePrincipalName"
    }
}
finally {
    $conn.Close();
}