<#
.SYNOPSIS
    Move the 'WEBSITE_VNET_ROUTE_ALL' application setting to the webapp config. 
.DESCRIPTION
    Move the 'WEBSITE_VNET_ROUTE_ALL' application setting to the webapp config. 
.EXAMPLE
    PS C:\> Azure.PlatformProvisioning\migration\Move-VnetRouteAllSettings.ps1 -AppType functionapp
    This script converts all the function apps for the current active azure cli account
.EXAMPLE
    PS C:\> Azure.PlatformProvisioning\migration\Move-VnetRouteAllSettings.ps1 -AppType webapp
    This script converts all the web applications for the current active azure cli account
.EXAMPLE
    PS C:\> Azure.PlatformProvisioning\migration\Move-VnetRouteAllSettings.ps1 -AppType functionapp -WhatIf
    This script shows what would be executed for all the function apps for the current active azure cli account
#>
[CmdletBinding()]
param (
    # Type of app to convert
    [Parameter(Mandatory)][ValidateSet('functionapp', 'webapp')][string]$AppType,

    # if used, the app is not changed only mentioned which change it would execute
    [Parameter()][switch]$WhatIf
)


    
$currentAccountName = (az account show | ConvertFrom-Json).name
Write-Host "Fetch all $AppType for '$currentAccountName'"
$apps = az $AppType list | ConvertFrom-Json

Write-Host "Getting the current state of all the $AppType"
$appSettings = $apps | ForEach-Object -Parallel {
    $app = $_
    function Get-AppSetRouteAll
    {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)][string]$ResourceGroupName,
            [Parameter(Mandatory)][string]$Name,
            [Parameter()][string]$DeploymentSlotName,
            [Parameter(Mandatory)][ValidateSet('functionapp', 'webapp')][string]$AppType
        )

        $additionalParameters = @()
        $DeploymentSlotNamestring = [string]::Empty
        if ($DeploymentSlotName)
        {
            $additionalParameters = '--slot' , $DeploymentSlotName
            $DeploymentSlotNamestring = "[$DeploymentSlotName]"
        } 

        Write-Host "processing $ResourceGroupName $Name$DeploymentSlotNamestring" -ForegroundColor Green
        $configSettings = az $AppType config show --resource-group $ResourceGroupName --name $Name @additionalParameters | ConvertFrom-Json  
        $appSettings = az $AppType config appsettings list --resource-group $ResourceGroupName --name $Name @additionalParameters | ConvertFrom-Json
        $vnetrouteall = $appSettings | Where-Object name -EQ 'WEBSITE_VNET_ROUTE_ALL'

        $collect = [PSCustomObject]@{
            ResourceGroup                 = $ResourceGroupName
            Name                          = $Name
            needToChange                  = $false
            CurrentVnetRouteAll           = $configSettings.vnetRouteAllEnabled
            CurrentWEBSITE_VNET_ROUTE_ALL = $vnetrouteall.value 
            DeploymentSlotName            = $DeploymentSlotName
            ShouldVNetRouteAllEnabled     = $false
        }

        if (($vnetrouteall -and $vnetrouteall.value -eq 1 ) -or $configSettings.vnetRouteAllEnabled)
        {
            $collect.ShouldVNetRouteAllEnabled = $true
        }

        if (($collect.ShouldVNetRouteAllEnabled -ne $collect.CurrentVnetRouteAll) -or ($vnetrouteall -and $vnetrouteall.value ))
        {

            Write-Host "Config settings vnetRouteAllEnabled is $($collect.CurrentVnetRouteAll), going to set to $($collect.ShouldVNetRouteAllEnabled)"
            Write-Host "WEBSITE_VNET_ROUTE_ALL in use: $($vnetrouteall -and $vnetrouteall.value)"
            $collect.needToChange = $true
        }

        Write-Output $collect
        Write-Host "processed $ResourceGroupName $Name$DeploymentSlotNamestring" -ForegroundColor Green
        if (!$DeploymentSlotName)
        {
            $DeploymentSlotNames = (az $AppType deployment slot list --resource-group $ResourceGroupName --name $Name | ConvertFrom-Json).name
            if ($DeploymentSlotNames)
            {
                $DeploymentSlotNames | ForEach-Object {
                    Get-AppSetRouteAll -ResourceGroup $ResourceGroupName -Name $Name -DeploymentSlotName $_ -AppType:$AppType
                }
            }
        }  
    }
    Get-AppSetRouteAll -ResourceGroupName $app.ResourceGroup -Name $app.name -AppType:$using:AppType
}

$appSettings | Out-GridView -Title 'apps to change - gridview'
if (!$WhatIf)
{
    $yes = [System.Management.Automation.Host.ChoiceDescription]::new('&Yes' , 'Apply all the changes')
    $no = [System.Management.Automation.Host.ChoiceDescription]::new('&No' , 'Do not change anything')
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice('Apply new settings', 'Do you want to apply all the new settings as shown in the gridview?', $options, 0)
    if ($result -eq 1)
    {
 
        Write-Host 'Not applying any changes'
        exit 0
    }
}
Write-Host 'Applying changes'

$appSettings | Where-Object needToChange | ForEach-Object -Parallel {
    $singleAppSettings = $_
    $additionalParameters = @()
    $DeploymentSlotNamestring = [string]::Empty
    if ($singleAppSettings.DeploymentSlotName)
    {
        $additionalParameters = '--slot' , $singleAppSettings.DeploymentSlotName
        $DeploymentSlotNamestring = "[$($singleAppSettings.DeploymentSlotName)]"
    }
   
    if ($singleAppSettings.ShouldVNetRouteAllEnabled -ne $singleAppSettings.CurrentVnetRouteAll)
    {
        Write-Host "$using:AppType $($singleAppSettings.Name)$DeploymentSlotNamestring setting vnetRouteAllEnabled '$($singleAppSettings.ShouldVNetRouteAllEnabled)'"
        if (!$using:WhatIf)
        {
            az $using:AppType config set --resource-group $singleAppSettings.ResourceGroup --name $singleAppSettings.Name --vnet-route-all-enabled $singleAppSettings.ShouldVNetRouteAllEnabled @additionalParameters
        }
        else
        {
            Write-Host "[WHATIF] az $using:AppType config set --resource-group $($singleAppSettings.ResourceGroup) --name $($singleAppSettings.Name) --vnet-route-all-enabled $($singleAppSettings.ShouldVNetRouteAllEnabled) $($additionalParameters)"
        }
    }
    if ($singleAppSettings.CurrentWEBSITE_VNET_ROUTE_ALL)
    {
        Write-Host "$using:AppType $($singleAppSettings.Name)$DeploymentSlotNamestring removing 'WEBSITE_VNET_ROUTE_ALL' setting"
        if (!$using:WhatIf)
        {
            az $using:AppType config appsettings delete --resource-group $singleAppSettings.ResourceGroup --name $singleAppSettings.Name --setting-names 'WEBSITE_VNET_ROUTE_ALL' @additionalParameters
        }
        else
        {
            Write-Host "[WHATIF] az $using:AppType config appsettings delete --resource-group $($singleAppSettings.ResourceGroup) --name $($singleAppSettings.Name) --setting-names 'WEBSITE_VNET_ROUTE_ALL' $($additionalParameters)"
        }
    }
}