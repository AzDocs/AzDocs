function Add-ScopedRoleAssignment
{
	[CmdletBinding(DefaultParameterSetName = 'Resource')]
	param (
		# Switches for which resource we are talking about
		[Parameter(Mandatory, ParameterSetName = 'Resource')][switch]$Resource,
		[Parameter(Mandatory, ParameterSetName = 'Scope')][switch]$Scope,
		# Parameters
		[Parameter(Mandatory, ParameterSetName = 'Resource')][ValidateNotNullOrEmpty()][string]$ResourceName,
		[Parameter(Mandatory, ParameterSetName = 'Resource')][ValidateNotNullOrEmpty()][string]$ResourceGroupName,
		[Parameter(Mandatory, ParameterSetName = 'Resource')][ValidateNotNullOrEmpty()][string]$ResourceType,
		[Parameter(Mandatory, ParameterSetName = 'Resource')][ValidateNotNullOrEmpty()][string]$ResourceNamespace,
		[Parameter(ParameterSetName = 'Resource')][string]$ParentResourcePath,
		[Parameter(Mandatory, ParameterSetName = 'Scope')][ValidateNotNullOrEmpty()][string]$PermissionScopeResourceId,
		[Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$RoleToAssign,
		[Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$AssigneeObjectId
	)

	Write-Header -ScopedPSCmdlet $PSCmdlet

	if (!$AssigneeObjectId)
	{
		throw "Could not find Managed Identity or no PrincipalId specified"	
	}

	if (-Not $Scope)
	{
		if ($ParentResourcePath)
		{
			$PermissionScopeResourceId = Invoke-Executable az resource show --resource-group $ResourceGroupName --name $ResourceName --namespace $ResourceNamespace --resource-type $ResourceType --parent $ParentResourcePath --query=id
		}
		else
		{
			$PermissionScopeResourceId = Invoke-Executable az resource show --resource-group $ResourceGroupName --name $ResourceName --namespace $ResourceNamespace --resource-type $ResourceType --query=id
		}
	}

	Write-Host "Assigning role $RoleToAssign to identity $AssigneeObjectId at scope $PermissionScopeResourceId"

	Invoke-Executable az role assignment create --role $RoleToAssign --assignee-object-id $AssigneeObjectId --scope $PermissionScopeResourceId

	Write-Footer -ScopedPSCmdlet $PSCmdlet
}