param(
    [string]$EventLogName,
    [int]$EventId,
    [string]$SearchString,
    [string]$OutputFormat,
    [string]$OutputFile
)

# Built-in event logs to search
$BuiltInEventLogs = @('sysmon', 'security', 'applocker', 'system', 'emet', 'windows defender', 'powershell operational', 'all')

function SelectEventLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$EventLogName
    )
    if ($EventLogName -in $BuiltInEventLogs) {
        return $EventLogName
    } else {
        Write-Host "`nInvalid choice, please select a valid event log from the list`n"
        $EventLogName = Read-Host "Please enter the event log name"
        SelectEventLog -EventLogName $EventLogName
    }
}

# Function to convert string to datetime object
function ConvertTo-DateTime {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Date
    )
    try {
        $convertedDate = [datetime]::ParseExact($Date, 'MM/dd/yyyy', $null)
        return $convertedDate
    }
    catch {
        Write-Host "`nInvalid date format, please use MM/DD/YYYY`n"
        return $null
    }
}

# main program starts here
try {
    Write-Host "The available event logs are:"
    Write-Host ($BuiltInEventLogs -join ', ')
    $EventLogName = Read-Host "`nPlease enter the event log name"
    $EventLogName = SelectEventLog -EventLogName $EventLogName

    # If 'all' is selected, iterate over a list of predefined event logs
    if ($EventLogName -eq 'all') {
        $EventLogNames = @('security', 'applocker', 'system', 'emet', 'windows defender', 'powershell operational') # enter more event logs as you see fit
    } else {
        $EventLogNames = @($EventLogName)
    }

    $SearchOption = Read-Host "`nEnter 1 to search for an event ID or 2 to enter a string to search in the event logs"
    $VerboseOption = Read-Host "`nEnter 1 for minimal fields or 2 for verbose output"
    
    # Add date range selection
    $DateRangeSelection = Read-Host "`nDo you want to enter a date range for the search? Enter yes or no"
    if ($DateRangeSelection -eq "yes") {
        Write-Host "`nEnter the date range to perform a targeted search (format: MM/DD/YYYY)"
        $StartDate = ConvertTo-DateTime -Date (Read-Host "Start date")
        $EndDate = ConvertTo-DateTime -Date (Read-Host "End date")

        $EndDate = $EndDate.AddDays(1).AddSeconds(-1)  # To include all events of the EndDate day
    }

    # Rest of the script continues...
    foreach ($EventLogName in $EventLogNames) {
        try {
            if ($SearchOption -eq 1) {
                $EventId = Read-Host "Enter the event ID to search for"
                if ($StartDate -and $EndDate) {
                    $Events += Get-WinEvent -FilterHashtable @{LogName=$EventLogName; Id=$EventId; StartTime=$StartDate; EndTime=$EndDate}
                } else {
                    $Events += Get-WinEvent -FilterHashtable @{LogName=$EventLogName; Id=$EventId}
                }
            } elseif ($SearchOption -eq 2) {
                $SearchString = Read-Host "Enter the search string"
                if ($StartDate -and $EndDate) {
                    $Events += Get-WinEvent -FilterHashtable @{LogName=$EventLogName; StartTime=$StartDate; EndTime=$EndDate} | Where-Object { $_.Message -like "*$SearchString*" }
                } else {
                    $Events += Get-WinEvent -FilterHashtable @{LogName=$EventLogName} | Where-Object { $_.Message -like "*$SearchString*" }
                }
            } else {
                Write-Host "`nInvalid choice, please select a valid option`n"
            }
        } catch {
            Write-Warning "Failed to query log $EventLogName. It might not exist on this system."
        }
    }


    $OutputOption = Read-Host "`nEnter 1 to output results to a grid view or 2 to export to a file (json or csv)"
    if ($OutputOption -eq 1) {
        $Events | Out-GridView
    } elseif ($OutputOption -eq 2) {
        $OutputFormat = Read-Host "`nEnter 1 for JSON format or 2 for CSV format"
        $OutputFile = Read-Host "`nEnter the output file path"
        if ($OutputFormat -eq 1) {
            $Events | ConvertTo-Json | Set-Content -Path $OutputFile
        } elseif ($OutputFormat -eq 2) {
            $Events | Export-Csv -Path $OutputFile -NoTypeInformation
        } else {
            Write-Host "`nInvalid choice, please select a valid format option`n"
        }
    } else {
        Write-Host "`nInvalid choice, please select a valid output option`n"
    }
} catch {
            Write-Warning "Failed to query log $EventLogName. It might not exist on this system."
        }
