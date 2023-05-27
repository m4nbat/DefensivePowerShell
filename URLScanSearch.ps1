# search fields, syntax, and API reference below:
# https://urlscan.io/docs/api/
# https://urlscan.io/docs/search/

# prompt for API key, search field and search keyword
$apiKey = Read-Host -Prompt 'Enter your API key'
$searchField = Read-Host -Prompt 'Enter the search field'
$searchKeyword = Read-Host -Prompt 'Enter the search keyword'

# API headers
$headers = @{
    'API-Key' = $apiKey
    'Content-Type' = 'application/json'
}

# perform search
$response = Invoke-RestMethod -Uri "https://urlscan.io/api/v1/search/?q=$($searchField):$($searchKeyword)" -Headers $headers -Method Get

# assuming $response contains the API response and $response.results contains the list of results
$urls = @()
$domains = @()
$ips = @()

foreach ($result in $response.results) {
    $urls += $result.page.url
    $domains += $result.page.domain
    $ips += $result.page.ip
}

# remove duplicates
$urls = $urls | Sort-Object | Get-Unique
$domains = $domains | Sort-Object | Get-Unique
$ips = $ips | Sort-Object | Get-Unique

# display distinct urls, domains, and ips
Write-Output "URLs:"
$urls | ForEach-Object { Write-Output $_ }
Write-Output "`nDomains:"
$domains | ForEach-Object { Write-Output $_ }
Write-Output "`nIPs:"
$ips | ForEach-Object { Write-Output $_ }

# create objects for CSV export
$csvData = @()
for ($i=0; $i -lt $urls.Count; $i++) {
    $csvData += New-Object PSObject -Property @{
        "URL" = $urls[$i]
        "Domain" = $domains[$i]
        "IP" = $ips[$i]
    }
}

# export to CSV
$csvData | Export-Csv -Path "urlscan_results.csv" -NoTypeInformation
