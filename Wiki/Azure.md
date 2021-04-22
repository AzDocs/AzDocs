[[_TOC_]]

# Introduction
Welcome on the azure documentation site of the Azure Platform Provisioning scripts (AzDocs).

The goal is to have snippets for creating Azure resources that are secure & compliant to the highest level of requirements.

Please note that this is a **Work In Progress** effort. Multiple companies are currently backing, contributing & using this for their production environments.

[Azure CLI](/Azure/Azure-CLI-Snippets)

# Why use this boilerplate
The idea behind this boilerplate is that everyone wants a secure stack without having to do the whole compliancy & security setup yourself. A good example is that in 2021 it's not acceptable that you use non SSL HTTP connections. This means that, in all the scripts we write, HTTPS will be enforced. You get these general sense choices for free in your application stack. Another good example is that we strive to enable full logging for all components to a central Log Analytics Workspace, so that if you need logging at some point, you will have it.

> TLDR; you don't want to figure out everything by yourself :).

# Core Concepts / Architecture
There are a few core concept in this boilerplate which are essential for a successful implementation. In this chapter those core concepts are described.
 - CICD is leading --> Your platform should be able to burn and we should be good to go.
    - This means your resources, variables & secrets etc. are provisioned from your CICD pipelines towards the Azure platform.
 - Backwards compatible; scripts which are created should not break previous versions unless it's absolutely not possible to create backwards compatibility.
 - You want to create a resourcegroup per application stack
    - This means your API, portal, database etc. which are needed for running your application are all in the same resourcegroup, but another application stack is in it's own resource group.
 - There is one or more shared resourcegroups for shared components
    - For example if you use an application gateway to expose multiple application stacks to the internet, this will be in a shared RG with for example the VNET which is shared between your platforms.
    - Those shared resources are mainly done for cost reductions. You dont want to host an Application Gateway for each application because it's simply unnecessary.

## Resource naming best practises
Make sure that when you start using this boilerplate you come up with a good naming convention for your implementation. There are a few general rules of thumb which you can follow to get a good naming scheme.
 - Use the same naming structure for all of your resourcegroups. For example `<Teamname>-<ApplicationStackName>-<EnvironmentName>` or simply ` <ApplicationStackName>-<EnvironmentName>`.
 - It's extremely recommended to use the Environment name in your resource names for easy understanding & easy automation.
    - In Azure DevOps Release pipelines you can use the `$(Release.EnvironmentName)` to use the current stage name for spinning up resources in your Azure platform. This means that if you name your stages `dev`, `acc` and `prd` that you can use `$(Release.EnvironmentName)` in your resources names which will cause the resources to include those `dev`, `acc` and `prd` references.
 - If you have only 1 instance of a specific resourcetype (now and in the future) in each resourcegroup, its recommended to just simply name the resource the same as your resourcegroup.
    - For example: you want 1 application insights resource per application stack. Just give the same name to the appinsights and the resourcegroup for simplicity sake.

## Zero trust architecture
TODO

## SaaS --> PaaS --> IaaS
TODO

## Azure CLI unless
TODO

## Pipelines
TODO

### Service Principal Setup
TODO

# Which components are available & when to use them?
TODO

# Prerequisites
TODO

# How to use the scripts
TODO

# Guidelines for creating new scripts
TODO

## Coding Convention
TODO

### Naming
TODO

# How to keep your repositories in sync with upstream
TODO

# Networking
TODO

## VNet Whitelisting
TODO

## Private Endpoints
TODO

### DNS
TODO

### How to deploy to private resources: Azure DevOps Private Agents
TODO

### VNET_ROUTE_ALL / DNS SERVER REFERENCE
TODO

## On-premises networks
TODO

# Logging
TODO

# Monitoring
TODO

# TODO
TLS 1.2 support for App Gateways in older onprem OS's: https://docs.microsoft.com/nl-nl/mem/configmgr/core/plan-design/security/enable-tls-1-2-client