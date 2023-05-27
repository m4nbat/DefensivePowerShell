# Purpose:

This repo contains PowerShell scripts that cover the following blue team areas:

## CTI

| Script | Description | Link |
|--|--|--|
| URLScan.io search | This script queries the URLScan.io search API. It prompts for an API key (free when you sign-up), search field to query [LINK](https://urlscan.io/docs/search/), and a query to search with. At present it returns the IP, Domain, and URL for any matches it finds.   | [LINK](https://github.com/m4nbat/DefensivePowerShell/blob/main/URLScanSearch.ps1) |
| Shodan ouput parser | This script prompts for a directory containing shodan results output files in JSON format. It then parses the domains and IPs from those output files. | [LINK](https://github.com/m4nbat/DefensivePowerShell/blob/main/ShodanJSONPowerShellParser.ps1) |
| Shodan search and results enrichment (Abuse.ch) | This script prompts the user for a Shodan API key and search term. It then retrieves and parses the IP addresses from the results and queries the abuse.ch threatfox API to identify any tags or malware that have been associated with the IP addresses  | [LINK](https://github.com/m4nbat/DefensivePowerShell/blob/main/ShodanSearchResultsAbuseChLookup.ps1) |
| VirusTotal API Search | This script allows for basic searches against the Virustotal API. It requires a Virustotal API key. | [LINK](https://github.com/m4nbat/DefensivePowerShell/blob/main/VTAPISearch.ps1) |
| Virust Total and Abuse.ch Search | This script allows for searching IPs, hashes and domains against the Virustotal and Abuse.ch API | [LINK](https://github.com/m4nbat/DefensivePowerShell/blob/main/ShodanSearchResultsAbuseChLookup.ps1) |


## Malware Analysis

| Script | Description | Link |
|--|--|--|
|  |  |  |

## Digital Forensics

| Script | Description | Link |
|--|--|--|
|  |  |  |

## Log Analysis

| Script | Description | Link |
|--|--|--|
|  |  |  |
