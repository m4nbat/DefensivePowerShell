# This script prompts the user for a Shodan API key and Shodan search term. 
# It then performs the shodan search stores the results and uses the IP addresses from the results to query the abuse.ch threatfox API.
# It then outputs these results as a csv file containing information on the IP addresses that it matched in the threatfox IOC search.


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

    # Process the Abuse.ch API response and save the data to the output
    if ($abuseResponse.data) {
        foreach ($record in $abuseResponse.data) {
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
        }
    }
    else {
        # No data found for the IP
        $ipOutput += [PSCustomObject]@{
            'ioc' = $match.ip_str
            'threat_type' = 'No results found'
            'malware' = 'No results found'
            'confidence_level' = 'No results found'
            'reporter' = 'No results found'
            'tags' = 'No results found'
            'first_seen' = 'No results found'
        }
    }
}

# Define the output directory
$directoryPath = ".\" # Replace with the desired output directory path

# Save IP addresses output to a CSV file
$ipOutput | Export-Csv -Path ("$directoryPath\IPAddresses.csv") -NoTypeInformation

# Reset the outputs for the next search
$ipOutput = @()
