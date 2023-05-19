# This script prompts the user for a Shodan API key and Shodan search term. 
# It then performs the shodan search stores the results and uses the IP addresses from the results to query the abuse.ch threatfox API.
# It then outputs these results as a csv file containing information on the IP addresses that it matched in the threatfox IOC search.


# Reset the outputs for the next search
$ipOutput = @()
$noMatchList = @()

# Prompt the user for the necessary information
$apiKey = Read-Host -Prompt "Enter your Shodan API key"
$searchQuery = Read-Host -Prompt "Enter your Shodan search query"

# Base URL for the Shodan API
$shodanBaseUrl = "https://api.shodan.io/shodan/host/search"

# Prepare the parameters for the API request
$shodanParams = @{
    'key'    = $apiKey
    'query'  = $searchQuery
    'facets' = 'country' # replace this with the actual facet value(s) if needed
}

# Execute the Shodan API request
$shodanResponse = Invoke-RestMethod -Uri $shodanBaseUrl -Body $shodanParams -Method Get

# Define Abuse.ch API URL
$abuseApiUrl = 'https://threatfox-api.abuse.ch/api/v1/'

# Process the Shodan search results
foreach ($match in $shodanResponse.matches) {
    Write-Output "Processing IP: $($match.ip_str)"

    # Query ThreatFox API
    $abuseResponse = Invoke-RestMethod -Method Post -Uri $abuseApiUrl -Body (ConvertTo-Json -Depth 10 @{
        'query' = 'search_ioc'
        'search_term' = $match.ip_str
    }) -ContentType 'application/json'

    # Initialize a variable to track whether any data was found for the current IP
    $dataFound = $false

    # Process the Abuse.ch API response and save the data to the output
if ($abuseResponse.data) {
    foreach ($record in $abuseResponse.data) {
        # Check if the ioc field is not null
        if ($record.ioc -ne $null) {
            # Save IP addresses output to a CSV file
            $ipOutput += [PSCustomObject]@{
                'ioc' = $record.ioc
                'threat_type' = $record.threat_type
                'malware' = $record.malware
                'confidence_level' = $record.confidence_level
                'reporter' = $record.reporter
                'tags' = $record.tags -join ', '  # Handle 'tags' as JSON array
                'first_seen' = $record.first_seen
            }

            # Since we found some data, set the tracking variable to true
            $dataFound = $true
        }
    }
}

    # If no data was found for the current IP, add it to the no-match list
    if (-not $dataFound) {
        # No data found for the IP
        $ipOutput += [PSCustomObject]@{
            'ioc' = $match.ip_str
            'threat_type' = 'No Data'
            'malware' = 'No Data'
            'confidence_level' = 'No Match'
            'reporter' = 'No Match'
            'tags' = 'No Match'
            'first_seen' = 'No Match'
        }

        $noMatchList += $match.ip_str
    }
}


# Rest of your script...

# Save IP addresses output to a CSV file
$ipOutput | Export-Csv -Path ("$directoryPath\IPAddresses.csv") -NoTypeInformation

# Prepare the summary statistics
$threatTypeCount = @{}
$malwareTypeCount = @{}

foreach ($output in $ipOutput) {
    # Skip 'No Data' entries
    if ($output.threat_type -ne 'No Data') {
        if ($threatTypeCount.ContainsKey($output.threat_type)) {
            $threatTypeCount[$output.threat_type]++
        } else {
            $threatTypeCount[$output.threat_type] = 1
        }
    }

    if ($output.malware -ne 'No Data') {
        if ($malwareTypeCount.ContainsKey($output.malware)) {
            $malwareTypeCount[$output.malware]++
        } else {
            $malwareTypeCount[$output.malware] = 1
        }
    }
}


Write-Output "`nResults Summary:"
Write-Output "Total Results: $totalResults"

Write-Output "`nThreat Types Breakdown:"
foreach ($key in $threatTypeCount.Keys) {
    Write-Output "$key : $($threatTypeCount[$key])"
}

Write-Output "`nMalware Types Breakdown:"
foreach ($key in $malwareTypeCount.Keys) {
    Write-Output "$key : $($malwareTypeCount[$key])"
}

Write-Output "`nNo Match List:"
foreach ($ioc in $noMatchList) {
    Write-Output $ioc
}
