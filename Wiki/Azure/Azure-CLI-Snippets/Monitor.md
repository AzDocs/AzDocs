[[_TOC_]]

# Monitor

Next to having Application Insights enabled for your application, you can add alerting to your application. We've got the following options:

## Monitor Action Groups

When you want to send out alerts for your applications, the first thing you need is a [Create-Monitor-Action-Group](/Azure/Azure-CLI-Snippets/Monitor/Create-Monitor-Action-Group).
In this group you can specify which action has to be taken, when an alert occurs. For example, this could be sending out a notification through email/sms or running an action like running an Automation Runbook, or triggering an Azure Function.

To be able to set this up, you can specify the `AlertAction`, e.g. : `@("webhook";"opsgenie";"https://api.opsgenie.com/v2/alerts apiKey={ApiKey} type=HighCPU";)`. To find a list of action types, go to: [Azure Actions](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups#action-specific-information).

## Log alert rules

Alerts are based upon certain rules, e.g. is my application's CPU between 80% and 100%? Then send out an alert.
In the script [Create-Log-Alert-Rule](/Azure/Azure-CLI-Snippets/Monitor/Create-Log-Alert-Rule) you are able to configure your alert rule and add it to a Monitor Action Group.
