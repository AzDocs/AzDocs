[[_TOC_]]

# Logging & Monitoring

_NOTE: This is not the final version of Logging & Monitoring. Several basic measures are in place, but it is not feature complete yet. Our roadmap contains epics to straighten this out._

For both logging & monitoring we envision that this is included, for the bigger part, in the resource creation scripts. So our goal is that, in the future, you will get dashboards, infra logging & monitoring out of the box using the AzDocs. A good example to explain this is that, whenever you run an App Service, you pretty much always want to know how your app service is doing. So the most basic thing to measure is how high or low your error rate is. And especially: whenever it deviates from the baseline. This means that in our app service creation scripts we could, by default, create alerts & dashboards for error rate basline deviation. And with this specific example, there are more examples you can think of which are generic for all platforms you run (CPU usage, memory usage etc). So in future versions this will be setup for you automatically using the AzDocs scripts.

To run a platform in production, you will need to have eyes & ears everywhere inside and around your platform. We know this and we try to solve this for you as painlessly as possible. We are using Log Analytics Workspace (LAW) as our main logging solution. On a conceptual level, we strive to send all the logs we have to a central LAW instance (one LAW for each `DTAP` stage). For example: you will see `az monitor diagnostic-settings create` commands in "create resource" scripts to send diagnostics to the LAW's as well. At the moment of writing, we attached the following components to the centralized LAW:

- Application Insights (Application Performance Monitoring & insights for your software stack & dependencies. This means that all your APM information is also sent to the centralized LAW)
- Diagnostics from resources (Infra level logging)
- Application Logging with Serilog (See [Application logging to Log Analytics Workspace using Serilog](#application-logging-to-log-analytics-workspace-using-serilog))
- SQL Auditing logs (see who is connecting to your databases and what is happening)
- Azure Sentinel (see platform auditing and security & enable alerting on auditing)
- In addition to the above, we've also added several solution types to the LAW so you can log your IaaS logging to the LAW as well. You can use [Log Analytics Workspace Agents](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/log-analytics-agent) for this

Centralizing the logging means that you can view and correlate (where possible ofcourse) all logging, simply because it is centralized. In our case we've decided to setup a LAW resource for each subscription. So all the resources inside a subscription logs towards the central LAW while still keeping stage separation in place.

For monitoring we use a combination of Azure Monitor & (its subproduct) Application Insights (AppInsights). As of yet we have scripts to enable AppInsights codeless into your webapps. However, we strongly recommend to include AppInsights through nuget into your software, because this simply gives more metrics & information than its codeless counterpart. As for Application Insights, we recommend to create an AppInsights per app stack (so all resources you need to run a specific app platform; log to the same AppInsights to see connections between those components). We've also added scripts to setup alerts from Azure Monitor to, for example, OpsGenie. (See [Create Monitor Action Group](/Azure/AzDocs-v1/Scripts/Monitor/Create-Monitor-Action-Group) & [Create Log Alert Rule](/Azure/AzDocs-v1/Scripts/Monitor/Create-Log-Alert-Rule)).

## Application logging to Log Analytics Workspace using Serilog

As described in [Logging & Monitoring](#logging-%26-monitoring), we are using Log Analytics Workspace (LAW) as our main logging solution. This also counts for our application logging. We use [Serilog](https://serilog.net/) in our .NET Stacks with the [Serilog Azure Analytics sink](https://github.com/saleem-mirza/serilog-sinks-azure-analytics) for logging our application logs to the LAW.

To provision the logging settings from your pipeline, use these appsettings for your function/appservice (make sure to replace the values accordingly):

```
"Serilog__MinimumLevel=Debug"; "Serilog__WriteTo__1__Name=AzureAnalytics"; "Serilog__WriteTo__1__Args__logName=TheNameOfTheLogYouWant"; "Serilog__WriteTo__1__Args__workspaceId=LogAnalyticsWorkspaceGuid"; "Serilog__WriteTo__1__Args__authenticationId=LogAnalyticsPrimaryKey"; "Serilog__WriteTo__2__Args__restrictedToMinimumLevel=Information"; "Serilog__WriteTo__2__Args__telemetryConverter=Serilog.Sinks.ApplicationInsights.Sinks.ApplicationInsights.TelemetryConverters.TraceTelemetryConverter, Serilog.Sinks.ApplicationInsights"; "Serilog__WriteTo__2__Name=ApplicationInsights"; "Serilog__Using__2=Serilog.Sinks.ApplicationInsights"; "Serilog__Using__1=Serilog.Sinks.AzureAnalytics";
```

The above will make sure that your application logging will also be sent to the central LAW.
