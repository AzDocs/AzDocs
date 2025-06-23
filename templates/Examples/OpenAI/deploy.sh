#!/bin/bash

# Azure OpenAI Deployment Script
# This script demonstrates how to deploy the Azure OpenAI modules

set -e

# Configuration
RESOURCE_GROUP_NAME="rg-openai-demo"
LOCATION="westeurope"
DEPLOYMENT_NAME="openai-deployment-$(date +%Y%m%d-%H%M%S)"
TEMPLATE_FILE="example-openai.bicep"
PARAMETERS_FILE="parameters.json"

echo "🚀 Starting Azure OpenAI deployment..."

# Check if Azure CLI is installed and user is logged in
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "❌ You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)

echo "📋 Deployment Configuration:"
echo "   Subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
echo "   Resource Group: $RESOURCE_GROUP_NAME"
echo "   Location: $LOCATION"
echo "   Template: $TEMPLATE_FILE"
echo "   Parameters: $PARAMETERS_FILE"
echo ""

# Create resource group if it doesn't exist
echo "🔍 Checking if resource group exists..."
if ! az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
    echo "📦 Creating resource group: $RESOURCE_GROUP_NAME"
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
else
    echo "✅ Resource group already exists: $RESOURCE_GROUP_NAME"
fi

# Validate the template
echo "🔍 Validating Bicep template..."
az deployment group validate \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "@$PARAMETERS_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Template validation successful"
else
    echo "❌ Template validation failed"
    exit 1
fi

# Deploy the template
echo "🚀 Deploying Azure OpenAI resources..."
az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "@$PARAMETERS_FILE" \
    --verbose

if [ $? -eq 0 ]; then
    echo "✅ Deployment completed successfully!"
    
    # Get deployment outputs
    echo "📊 Deployment outputs:"
    az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs
        
    echo ""
    echo "🎉 Azure OpenAI deployment completed!"
    echo "🔗 You can view your resources in the Azure Portal:"
    echo "   https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
else
    echo "❌ Deployment failed"
    exit 1
fi
