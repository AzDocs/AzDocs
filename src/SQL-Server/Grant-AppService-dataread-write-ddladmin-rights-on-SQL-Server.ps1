[CmdletBinding()]
param (
    [Parameter(Mandatory)][string] $SqlServerResourceGroupName,
    [Parameter(Mandatory)][string] $SqlServerName,
    [Parameter(Mandatory)][string] $SqlDatabaseName,
    [Parameter()][string] $ServiceUserEmail,
    [Parameter()][string] $ServiceUserObjectId,
    [Parameter()][string] $ServiceUserPassword,
    [Parameter(Mandatory)][string] $AppServiceName,
    [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
    [Parameter()][string] $AppServiceSlotName,
    [Parameter()][bool] $ApplyToAllSlots = $false
)

#region ===BEGIN IMPORTS===
Import-Module "$PSScriptRoot\..\AzDocs.Common" -Force
#endregion ===END IMPORTS===

Write-Header -ScopedPSCmdlet $PSCmdlet

function New-PrincipalName()
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $AppServicePrincipalName,
        [Parameter(Mandatory)][string] $SqlServerName,
        [Parameter(Mandatory)][string] $SqlDatabaseName,
        [Parameter(Mandatory)][string] $AccessToken
    )

    Write-Host "Opening database connection for ensuring the managed identity of $AppServicePrincipalName"

    # NOTE: For the following you will need to assign Directory Readers: https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal-tutorial#assign-directory-readers-permission-to-the-sql-logical-server-identity
    $sql = @"
    IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = '$AppServicePrincipalName')
        BEGIN
            CREATE USER [$AppServicePrincipalName] FROM EXTERNAL PROVIDER;
            ALTER ROLE db_datareader ADD MEMBER [$AppServicePrincipalName];
            ALTER ROLE db_datawriter ADD MEMBER [$AppServicePrincipalName];
            ALTER ROLE db_ddladmin ADD MEMBER [$AppServicePrincipalName];
        END
"@
    
    $conn = [System.Data.SqlClient.SqlConnection]::new()
    try
    {
        $conn.ConnectionString = "Server=tcp:$($SqlServerName).database.windows.net,1433;Initial Catalog=$($SqlDatabaseName);Persist Security Info=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        $conn.AccessToken = $AccessToken
        $conn.Open()
        $cmd = [System.Data.SqlClient.SqlCommand]::new($sql, $conn)
        if ($cmd.ExecuteNonQuery() -ne -1)
        {
            Write-Host "Failed to add the managed identity for $AppServicePrincipalName"
        }
    }
    finally
    {
        $conn.Close()
    }
}

if ($ApplyToAllSlots -eq $true)
{
    $slots = (Invoke-Executable az webapp deployment slot list --name $AppServiceName --resource-group $AppServiceResourceGroupName | ConvertFrom-Json).name
}

$AccessToken = $null

# Check if we need to login with a custom AAD user before doing actions on SQL.
if ($ServiceUserEmail -and $ServiceUserObjectId -and $ServiceUserPassword)
{
    try
    {
        $altIdProfilePath = Join-Path ([io.path]::GetTempPath()) '.azure-altId'
        $env:AZURE_CONFIG_DIR = $altIdProfilePath
        Invoke-Executable az login --username $ServiceUserEmail --password $ServiceUserPassword --allow-no-subscriptions
        $AccessToken = (Invoke-Executable az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
    }
    finally
    {
        $env:AZURE_CONFIG_DIR = $null
        Remove-Item -Recurse -Force $altIdProfilePath
    }
}
else
{
    $AccessToken = (Invoke-Executable az account get-access-token --resource https://database.windows.net | ConvertFrom-Json).accessToken
}

if (!$AccessToken)
{
    throw 'Could not fetch access token, something went wrong.'
}

$appServicePrincipalName = $AppServiceName
if ($slots)
{
    foreach ($slot in $slots)
    {
        $appServicePrincipalSlotName = "$($AppServiceName)/slots/$($slot)"
        New-PrincipalName -AppServicePrincipalName $appServicePrincipalSlotName -SqlServerName $SqlServerName -SqlDatabaseName $SqlDatabaseName -AccessToken $AccessToken
    } 
}

if ($AppServiceSlotName)
{
    $appServicePrincipalName += "/slots/$AppServiceSlotName"
}

New-PrincipalName -AppServicePrincipalName $appServicePrincipalName -SqlServerName $SqlServerName -SqlDatabaseName $SqlDatabaseName -AccessToken $AccessToken

Write-Footer -ScopedPSCmdlet $PSCmdlet