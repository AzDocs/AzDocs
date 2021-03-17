function Get-ObjectIdForLoggedInUser {
    [OutputType([string])]
    param ()

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Fetch the Identity ID of the logged in user
    $userIdentity = (Invoke-Executable az account show | ConvertFrom-Json).user
    if($userIdentity.type -eq 'user')
    {
        Write-Verbose "Fetching object id"
        $objectId = (Invoke-Executable az ad signed-in-user show | ConvertFrom-Json).objectId
    }
    else
    {
        Write-Verbose "Fetching identity id"
        $identityId = $userIdentity.name
        Write-Verbose "identityId: $identityId"
        Write-Verbose "Fetching object id"
        $objectId = (Invoke-Executable az ad sp show --id $identityId | ConvertFrom-Json).objectId
    }
    Write-Verbose "objectId: $objectId"
    
    Write-Footer -ScopedPSCmdlet $PSCmdlet

    return $objectId
}