# Write-Host 'Enter your API key for VirusTotal'
$apikey = "YOUR API KEY" #Read-Host
Write-Host 'Choose your search type (1 for Hash, 2 for Domain, 3 for IP, 4 for ThreatFox IOC, 5 for ThreatFox Hash, 6 for ThreatFox Tag, 7 for ThreatFox Malware)'
$choice = Read-Host
Write-Host 'Please enter your input based on the choice (single value or path to CSV file)'
$input = Read-Host
Write-Host 'Please enter your output filename'
$outputfile = Read-Host

$headers = @{
    'x-apikey' = $apikey
}

$items = if ((Test-Path $input) -and ($input -match '\.csv$')) {
    Import-Csv -Path $input -Header 'Value' | ForEach-Object { $_.Value }
} else {
    $input
}

switch ($choice) {
    1 {
        # Hash search
        foreach ($hash in $items) {
            Write-Host $hash
            $url = "https://www.virustotal.com/vtapi/v2/file/report?apikey=$apikey&resource=$hash"
            $response = Invoke-RestMethod -Method Get -Uri $url
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
        Get-Content $outputfile | Select-String 'scan_id', 'sha256', 'sha1', 'md5', 'scan_date', 'permalink', 'total', 'positives'
    }
    2 {
        # Domain search
        foreach ($domain in $items) {
            $url = "https://www.virustotal.com/api/v3/domains/$domain"
            $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
    }
    3 {
        # IP search
        foreach ($ip in $items) {
            $url = "https://www.virustotal.com/api/v3/ip_addresses/$ip"
            $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
    }
    4 {
        # ThreatFox IOC search
        foreach ($search_term in $items) {
            $url = "https://threatfox-api.abuse.ch/api/v1/"
            $body = @{
                "query" = "search_ioc"
                "search_term" = $search_term
            }
            $response = Invoke-RestMethod -Method Post -Uri $url -Body (ConvertTo-Json $body) -ContentType 'application/json'
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
    }
    5 {
        # ThreatFox Hash search
        foreach ($hash in $items) {
            $url = "https://threatfox-api.abuse.ch/api/v1/"
            $body = @{
                "query" = "search_hash"
                "hash" = $hash
            }
            $response = Invoke-RestMethod -Method Post -Uri $url -Body (ConvertTo-Json $body) -ContentType 'application/json'
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
    }
    6 {
        # ThreatFox Tag search
        foreach ($tag in $items) {
            $url = "https://threatfox-api.abuse.ch/api/v1/"
            $body = @{
                "query" = "taginfo"
                "tag" = $tag
                "limit" = 10
            }
            $response = Invoke-RestMethod -Method Post -Uri $url -Body (ConvertTo-Json $body) -ContentType 'application/json'
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
    }
    7 {
        # ThreatFox Malware search
        foreach ($malware in $items) {
            $url = "https://threatfox-api.abuse.ch/api/v1/"
            $body = @{
                "query" = "malwareinfo"
                "malware" = $malware
                "limit" = 10
            }
            $response = Invoke-RestMethod -Method Post -Uri $url -Body (ConvertTo-Json $body) -ContentType 'application/json'
            $response | ConvertTo-Json | Add-Content -Path $outputfile
            Start-Sleep -Seconds 15
        }
    }
    default {
        Write-Host 'Invalid choice. Please enter 1, 2, 3, 4, 5, 6 or 7.'
    }
}

Write-Host 'Data appended to a file called ' $outputfile
