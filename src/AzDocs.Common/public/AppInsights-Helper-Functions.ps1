function SetAppInsightsForFunctionApp($AppInsightsName, $AppInsightsResourceGroupName, $FunctionAppName, $FunctionAppResourceGroupName, $AppServiceSlotName)
{
    # Fetch the AppInsights connection information
    $appInsightsSettings = Invoke-Executable az resource show --resource-group $AppInsightsResourceGroupName --name $AppInsightsName --resource-type "Microsoft.Insights/components" | ConvertFrom-Json
    $connectionString = $appInsightsSettings.properties.ConnectionString
    $appInsightsKey = $appInsightsSettings.properties.InstrumentationKey

    $additionalParameters = @()
    if ($AppServiceSlotName) {
        $additionalParameters += '--slot' , $AppServiceSlotName
    }

    # set the key on the web app  (codeless application insights)
    Invoke-Executable az functionapp config appsettings set --name $FunctionAppName --resource-group $FunctionAppResourceGroupName @additionalParameters --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$appInsightsKey"
    Invoke-Executable az functionapp config appsettings set --name $FunctionAppName --resource-group $FunctionAppResourceGroupName @additionalParameters --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$connectionString"
}

function SetAppInsightsForAppService($AppInsightsName, $AppInsightsResourceGroupName, $AppServiceName, $AppServiceResourceGroupName, $AppServiceSlotName)
{
    # Fetch the AppInsights connection information
    $appInsightsSettings = Invoke-Executable az resource show --resource-group $AppInsightsResourceGroupName --name $AppInsightsName --resource-type "Microsoft.Insights/components" | ConvertFrom-Json
    $connectionString = $appInsightsSettings.properties.ConnectionString
    $appInsightsKey = $appInsightsSettings.properties.InstrumentationKey

    $additionalParameters = @()
    if ($AppServiceSlotName) {
        $additionalParameters += '--slot' , $AppServiceSlotName
    }

    # set the key on the web app  (codeless application insights)
    Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters --settings "APPINSIGHTS_INSTRUMENTATIONKEY=$appInsightsKey"
    Invoke-Executable az webapp config appsettings set --resource-group $AppServiceResourceGroupName --name $AppServiceName @additionalParameters --settings "APPLICATIONINSIGHTS_CONNECTION_STRING=$connectionString"
}