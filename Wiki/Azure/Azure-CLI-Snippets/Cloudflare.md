[[_TOC_]]

# Cloudflare

This section is a little different from the other scripts you can find in the AzDocs since Cloudflare is not Azure. However, Cloudflare is a widely used service for multiple reasons. Despite there are numerous options and services that Cloudflare offers, we currently only use it's reverse dns (with Anti-DDoS & WAF) feature and it's DNS feature. We strongly recommend you using Cloudflare when you don't want to use an Application Gateway for a security layer which you will miss without either Cloudflare (with Reverse Proxy enabled) or an Application Gateway (with WAF).

To help you use this as well we've added a script to the AzDocs which creates DNS records (with or without reverse proxy service) for you. This is very useful for when you want to automate the DNS for your own domains in combination with, for example, App Services.

You can simply set a Cloudflare DNS entry using the [Set-CloudflareCNAME](/Azure/Azure-CLI-Snippets/Cloudflare/Set-CloudflareCNAME) script.
