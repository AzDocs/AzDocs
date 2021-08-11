
function Set-AppServiceRunTime
{
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $AppServiceName,
        [Parameter(Mandatory)][string] $AppServiceResourceGroupName,
        [Parameter(Mandatory)][string] $AppServiceRunTime
    )

    Write-Header -ScopedPSCmdlet $PSCmdlet

    # Update RunTime
    $AppServiceRunTimeSplitted = $AppServiceRunTime.Replace("`"", "") -split "\|"
    Write-Host "AppServiceRunTimeSplitted: $AppServiceRunTimeSplitted"
    if ($tagSplitted.length -eq 2)
    {
        Write-Host "Updating runtime to Stack $($AppServiceRunTimeSplitted[0]) with version $($AppServiceRunTimeSplitted[1])"

        $stack = $AppServiceRunTimeSplitted[0]
        $stackVersion = $AppServiceRunTimeSplitted[1]

        $json = (([ordered]@{
                    siteConfig = @{
                        metadata            = @(
                            @{
                                name  = "CURRENT_STACK";
                                value = "$stack"
                            }
                        )
                        netFrameworkVersion = "v$($stackVersion)"
                    }
                }) | ConvertTo-Json -Depth 10 -Compress).Replace("`"", """""");

        Invoke-Executable az resource create --resource-group $AppServiceResourceGroupName --name $AppServiceName --resource-type "Microsoft.Web/sites/config" --properties `"$($json)`"
    }
    else
    {
        Write-Host "Couldn't find version & stack from AppServiceRunTime parameter ($($AppServiceRunTime))."
    }

    Write-Footer -ScopedPSCmdlet $PSCmdlet
}