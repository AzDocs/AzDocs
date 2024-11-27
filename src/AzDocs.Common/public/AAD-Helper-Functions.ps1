function Add-MemberToAADRole
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $PrincipalId,
        [Parameter(Mandatory)][string] $RoleName
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet
    
    # Define parameters for Microsoft Graph access token retrieval
    $access_token = (Invoke-Executable az account get-access-token --resource-type ms-graph | ConvertFrom-Json).accessToken
   
    $resource = 'https://graph.microsoft.com'
    $betaResource = 'https://graph.microsoft.com/beta'

    if (!$access_token)
    {
        throw 'AccessToken empty. Cannot continue.'
    }

    $headers = @{
        Authorization = "Bearer $access_token"
    }

    try
    {
        # Get Role
        $uri = "$($betaResource)/directoryRoles"
        $roles = (Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ContentType 'application/json').value
        $role = $roles | Where-Object { $_.displayName -eq $RoleName }
        $roleId = $role.id
        Write-Host "$($RoleName) role found with ID: $roleId" -ForegroundColor Green
    }
    catch
    {
        Show-RestError -Exception $_
    }

    try
    {
        # Check if member already exists in role
        $uri = "$($betaResource)/directoryRoles/$($roleId)/members"
        $roleMembers = (Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -ContentType 'application/json').value
        if (($roleMembers | Where-Object { $_.id -eq $PrincipalId }).Length -gt 0)
        {
            Write-Host "Member $($PrincipalId) already exists in the $($RoleName) role." -ForegroundColor Green
            return
        }
    }
    catch
    {
        Show-RestError -Exception $_
    }

    try
    {
        # Add member to roles
        $uri = "$($betaResource)/directoryRoles/$($roleId)/members/" + '$ref'
        $body = @{
            '@odata.id' = "$($betaResource)/directoryObjects/$($PrincipalId)"
        }
        Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body ($body | ConvertTo-Json) -ContentType 'application/json'
        Write-Host "Added member $($PrincipalId) to the $($RoleName) role." -ForegroundColor Green
    }
    catch
    {
        Show-RestError -Exception $_
    }
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet
}