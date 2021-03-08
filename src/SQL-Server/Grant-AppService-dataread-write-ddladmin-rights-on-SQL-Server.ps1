[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlDatabaseName,
    [Parameter(Mandatory)][string] $ServiceUserEmail,
    [Parameter(Mandatory)][string] $ServiceUserObjectId,
    [Parameter(Mandatory)][string] $ServiceUserPassword,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter()][string] $AppServiceSlotName
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

Invoke-Executable az sql server ad-admin create --resource-group $SqlServerResourceGroupName --server-name $SqlServerName --display-name $ServiceUserEmail --object-id $ServiceUserObjectId

$altIdProfilePath = Join-Path ([io.path]::GetTempPath()) '.azure-altId'
$AccessToken = $null
try {
    $env:AZURE_CONFIG_DIR = $altIdProfilePath

    Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions
    $AccessToken = (Invoke-Executable az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
}
finally {
    $env:AZURE_CONFIG_DIR = $null
    Remove-Item -Recurse -Force $altIdProfilePath
}
if(!$AccessToken){
    throw 'Could not fetch access token, something went wrong.'
}

$appServicePrincipalName = $AppServiceName
if ($AppServiceSlotName) {
    $appServicePrincipalName += "/slots/$AppServiceSlotName"
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
    $conn.ConnectionString = "Server=tcp:$($SqlServerName).database.windows.net,1433;Initial Catalog=$($SqlDatabaseName);Persist Security Info=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
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

Write-Footer -ScopedPSCmdlet $PSCmdlet