[CmdletBinding()]
param (
    [Parameter()]
    [String] $sqlServerResourceGroupName,

    [Parameter()]
    [String] $sqlServerName,

    [Parameter()]
    [String] $sqlDatabaseName,

    [Parameter()]
    [String] $serviceUserEmail,

    [Parameter()]
    [String] $serviceUserObjectId,

    [Parameter()]
    [String] $serviceUserPassword,

    [Parameter()]
    [String] $appServiceName
)

#region ===BEGIN IMPORTS===
. "$PSScriptRoot\..\common\Invoke-Executable.ps1"
#endregion ===END IMPORTS===

Invoke-Executable az sql server ad-admin create --resource-group $sqlServerResourceGroupName --server-name $sqlServerName --display-name $serviceUserEmail --object-id $serviceUserObjectId

Invoke-Executable az login --username $serviceUserEmail --password $serviceUserPassword --allow-no-subscriptions

$AccessToken = (Invoke-Executable az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
$conn = [System.Data.SqlClient.SqlConnection]::new()
$conn.ConnectionString = "Server=tcp:$($sqlServerName).database.windows.net,1433;Initial Catalog=$($sqlDatabaseName);Persist Security Info=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
$conn.AccessToken = $AccessToken
$conn.Open()

$cmd = [System.Data.SqlClient.SqlCommand]::new("IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = '$($appServiceName)') BEGIN CREATE USER [$($appServiceName)] FROM EXTERNAL PROVIDER;ALTER ROLE db_datareader ADD MEMBER [$($appServiceName)];ALTER ROLE db_datawriter ADD MEMBER [$($appServiceName)];ALTER ROLE db_ddladmin ADD MEMBER [$($appServiceName)]; END;", $conn);
if ($cmd.ExecuteNonQuery() -ne -1)
{
    Write-Host "Failed";
}

$conn.Close();