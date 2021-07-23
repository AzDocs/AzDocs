[[_TOC_]]

# Introduction to AzDocs
Welcome on the AzDocs (Azure Documentation) Wiki.

The AzDocs are a boilerplate & knowledgebase to get you and your team started with Azure in no time while keeping Security & Compliancy in place. The goal is to have snippets for creating Azure resources that are secure & compliant to the highest level of requirements along with examples and best practices. This library does have a bias about certain things which, in our experience, gets your team started faster.

> NOTE: This is a **Work In Progress** effort. Multiple (larger and smaller) companies are currently backing, contributing & using this for their business critical production environments.

## [Documentation](/Azure/Documentation)
We recommend looking at the documentation before going into the scripts. You can find this documentation here: [Documentation](/Azure/Documentation)

## [Scripts](/Azure/Azure-CLI-Snippets)
Or you can go straight to the scripts: [Azure CLI](/Azure/Azure-CLI-Snippets)

# Why use this boilerplate
The idea behind this boilerplate is that everyone wants a secure stack without having to do the whole compliancy & security setup yourself. A good example is that in 2021 it's not acceptable that you use non SSL HTTP connections. This means that, in all the scripts we write, HTTPS will be enforced. You get these general sense choices for free in your application stack. Another good example is that we strive to enable full logging for all components to a central Log Analytics Workspace, so that if you need logging at some point, you will have it.

> TLDR; you don't want to figure out everything by yourself and build secure & compliant platforms :).

Another major reason/benefit to use this boilerplate is because we fixed Azure CLI in Azure DevOps Pipelines. By default, whenever a CLI statement crashes, your pipeline does not always break. We've wrapped all of our statements into the so called `Invoke-Executable` statement which manages this behaviour for you. Next to this huge benefit, it adds another huge benefit: logging. Don't you hate the way of logging within our pipelines? We do too! So we've improved the logging when using this boilerplate. Let me simply show you by a screenshot:

![AzDocs - Invoke Executable](../wiki_images/azdocs_invoke_executable.png)

As you can see, all parameters get printed (secrets will be hidden ofcourse!) and and all actual CLI statements that are being done by the scripts are printed as well. This allows you to quickly debug & fix things going wrong in your pipelines!

And last but certainly not least: we've unified the way to enable debug information in your pipeline & Azure CLI. It's as simple as setting the default `System.Debug` to `true` in your pipeline variables. The `Invoke-Executable` wrapper will make sure the CLI statements will be appended with `--debug`!