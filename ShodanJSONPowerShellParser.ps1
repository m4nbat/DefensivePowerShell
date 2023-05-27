# Prompt for directory path
$directoryPath = Read-Host -Prompt 'Input your directory path containing shodan json output files'

# Check if directory exists
if (-not (Test-Path $directoryPath -PathType Container)) {
    Write-Output "Directory does not exist: $directoryPath"
    return
}

# Get all json files in the directory
$jsonFiles = Get-ChildItem -Path $directoryPath -Filter *.json

# Process each file
foreach ($inputFile in $jsonFiles) {
    Write-Output "Processing file: $($inputFile.FullName)"
    
    # Extract domains
    $domains = Select-String -Path $inputFile.FullName -Pattern '"domains": \["(([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+)"\]' -AllMatches |
    ForEach-Object {
        $_.Matches | ForEach-Object {
            $_.Groups[1].Value
        }
    } | Sort-Object -Unique

    # Check if any domains were found
    if ($domains.Count -eq 0) {
        Write-Output "No domains found in file: $($inputFile.FullName)"
    }
    else {
        # Write domains to a file
        $domains | Set-Content -Path ($inputFile.FullName + '-out-domain.txt')
    }

    # Extract IP addresses
    $ipAddresses = Select-String -Path $inputFile.FullName -Pattern '"ip_str":\s+"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"' -AllMatches |
    ForEach-Object {
        $_.Matches | ForEach-Object {
            $_.Groups[1].Value
        }
    } | Sort-Object -Unique

    # Write IP addresses to a file
    $ipAddresses | Set-Content -Path ($inputFile.FullName + '-out-ip.txt')
}
