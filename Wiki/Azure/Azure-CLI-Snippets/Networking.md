[[_TOC_]]

# Networking

For more information about networking, see [Recommended-Architecture](/Azure/Documentation/Recommended-Architecture)
To be able to set this up, we have added the following:

## VNET

To be able to use VNET Whitelisting (as is recommended), you will first need to setup a VNET with subnets. When using the script [Create-subnet-with-VNET-if-needed)](</Azure/Azure-CLI-Snippets/Networking/Create-subnet-(with-VNET-if-needed)>), a VNET and a subnet will be created based upon the address spaces (in CIDR notation) and the names you provided for the VNET and subnet.

In regards to the VNET, we have added some extra scripts to be able to configure a custom [DNS Server](/Azure/Azure-CLI-Snippets/Networking/Add-Custom-DNS-Server-To-VNET) and to add [DDoS protection](/Azure/Azure-CLI-Snippets/Networking/Add-DDoS-Protection-To-Vnet).

## VPN

We also have scripts that enable you to connect to the virtual network from an individual client computer or from an on-premise network(if needed), see [Create-Point-to-Site-VPN](/Azure/Azure-CLI-Snippets/Networking/Create-Point-to-Site-VPN) and [Create-Site-to-Site-VPN](/Azure/Azure-CLI-Snippets/Networking/Create-site-to-Site-VPN).
