[CmdletBinding()]
param (
	[Parameter(Mandatory)][string] $CloudflareApiToken,
	[Parameter(Mandatory)][string] $RootDomain,
	[Parameter()][string] $SubDomain,
	[Parameter(Mandatory)][bool] $CloudflareProxied,
	[Parameter(Mandatory)][string] $TargetCName
)

$baseurl = 'https://api.cloudflare.com/client/v4/zones'
$zoneurl = "$baseurl/?name=$RootDomain"

# To login use...
$headers = @{
	'Authorization' = "Bearer $CloudflareApiToken"
}

if ($SubDomain)
{
	$FullDnsEntry = "$SubDomain.$RootDomain"
}
else
{
	$FullDnsEntry = $RootDomain
}

Write-Host "FulLDnsEntry: $FullDnsEntry"
 
# Get Zone info
$zone = Invoke-RestMethod -Uri $zoneurl -Method Get -Headers $headers
$zoneid = $zone.result.id
 
$SubDomainurl = "$baseurl/$zoneid/dns_records/?name=$FullDnsEntry"
 
# Get current DNS record
$dnsrecord = Invoke-RestMethod -Uri $SubDomainurl -Method Get -Headers $headers
 
Write-Host "dnsrecord: $dnsrecord"

# If it exists, update, if not, add
if ($dnsrecord.result.count -gt 0)
{
 
	$SubDomainid = $dnsrecord.result.id	
	$dnsrecord.result | Add-Member 'content' $TargetCName -Force
	$dnsrecord.result | Add-Member 'proxied' $CloudflareProxied -Force
	$body = $dnsrecord.result | ConvertTo-Json 
	
	$updateurl = "$baseurl/$zoneid/dns_records/$SubDomainid/" 
	$result = Invoke-RestMethod -Uri $updateurl -Method Put -Headers $headers -Body $body
	
	Write-Output "Record $FullDnsEntry has been updated to the CNAME $($result.result.content)"
	
}
else
{
	$newrecord = @{
		'type'    = 'CNAME'
		'name'    = "$FullDnsEntry"
		'content' = $TargetCName
		'proxied' = $CloudflareProxied
	}
	
	$body = $newrecord | ConvertTo-Json
	$newrecordurl = "$baseurl/$zoneid/dns_records"
	$request = Invoke-RestMethod -Uri $newrecordurl -Method Post -Headers $headers -Body $body -ContentType 'application/json'
	Write-Output "New record $FullDnsEntry has been created with the ID $($request.result.id)"
}