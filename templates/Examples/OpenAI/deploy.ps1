# Azure OpenAI Deployment Script (PowerShell)
# This script demonstrates how to deploy the Azure OpenAI modules

param(
    [string]$ResourceGroupName = "rg-openai-demo",
    [string]$Location = "westeurope",
    [string]$TemplateFile = "example-openai.bicep",
    [string]$ParametersFile = "parameters.json"
)

$ErrorActionPreference = "Stop"

# Configuration
$DeploymentName = "openai-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "🚀 Starting Azure OpenAI deployment..." -ForegroundColor Green

# Check if Azure PowerShell is installed and user is logged in
try {
    $context = Get-AzContext
    if (-not $context) {
        throw "Not logged in"
    }
}
catch {
    Write-Host "❌ You are not logged in to Azure. Please run 'Connect-AzAccount' first." -ForegroundColor Red
    exit 1
}

# Get current subscription info
$subscription = Get-AzContext
$subscriptionId = $subscription.Subscription.Id
$subscriptionName = $subscription.Subscription.Name

Write-Host ""
Write-Host "📋 Deployment Configuration:" -ForegroundColor Cyan
Write-Host "   Subscription: $subscriptionName ($subscriptionId)" -ForegroundColor White
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Template: $TemplateFile" -ForegroundColor White
Write-Host "   Parameters: $ParametersFile" -ForegroundColor White
Write-Host ""

# Create resource group if it doesn't exist
Write-Host "🔍 Checking if resource group exists..." -ForegroundColor Yellow
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if (-not $resourceGroup) {
    Write-Host "📦 Creating resource group: $ResourceGroupName" -ForegroundColor Blue
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}
else {
    Write-Host "✅ Resource group already exists: $ResourceGroupName" -ForegroundColor Green
}

# Test the deployment
Write-Host "🔍 Validating Bicep template..." -ForegroundColor Yellow
try {
    Test-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile
    
    Write-Host "✅ Template validation successful" -ForegroundColor Green
}
catch {
    Write-Host "❌ Template validation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Deploy the template
Write-Host "🚀 Deploying Azure OpenAI resources..." -ForegroundColor Blue
try {
    $deployment = New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -Name $DeploymentName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile `
        -Verbose
    
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    
    # Display deployment outputs
    if ($deployment.Outputs) {
        Write-Host ""
        Write-Host "📊 Deployment outputs:" -ForegroundColor Cyan
        $deployment.Outputs | Format-Table -AutoSize
    }
    
    Write-Host ""
    Write-Host "🎉 Azure OpenAI deployment completed!" -ForegroundColor Green
    Write-Host "🔗 You can view your resources in the Azure Portal:" -ForegroundColor Cyan
    Write-Host "   https://portal.azure.com/#@/resource/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName" -ForegroundColor Blue
}
catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
