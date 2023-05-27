param(
    [string]$EventLogName,
    [int]$EventId,
    [string]$SearchString,
    [string]$OutputFormat,
    [string]$OutputFile
)

# Built-in event logs to search
$BuiltInEventLogs = @('sysmon', 'security', 'applocker', 'system', 'emet', 'windows defender', 'powershell operational')

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

# main program starts here
try {
    Write-Host "The available event logs are:"
    Write-Host ($BuiltInEventLogs -join ', ')

    $EventLogName = Read-Host "`nPlease enter the event log name"
    $EventLogName = SelectEventLog -EventLogName $EventLogName

    $SearchOption = Read-Host "`nEnter 1 to search for an event ID or 2 to enter a string to search in the event logs"
    $VerboseOption = Read-Host "`nEnter 1 for minimal fields or 2 for verbose output"
    
    if ($SearchOption -eq 1) {
        $EventId = Read-Host "Enter the event ID to search for"
        if ($VerboseOption -eq 1) {
            $Events = Get-WinEvent -FilterHashtable @{logname=$EventLogName; id=$EventId}
        } else {
            $Events = Get-WinEvent -FilterHashtable @{logname=$EventLogName; id=$EventId} | Select-Object *
        }
    } elseif ($SearchOption -eq 2) {
        $SearchString = Read-Host "Enter the search string"
        if ($VerboseOption -eq 1) {
            $Events = Get-WinEvent -FilterHashtable @{logname=$EventLogName} | Where-Object {$_.Message -like "*$SearchString*"}
        } else {
            $Events = Get-WinEvent -FilterHashtable @{logname=$EventLogName} | Where-Object {$_.Message -like "*$SearchString*"} | Select-Object *
        }
    } else {
        Write-Host "`nInvalid choice, please select a valid option`n"
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
            Write-Host "`nInvalid choice, please select a valid format`n"
        }
    } else {
        Write-Host "`nInvalid choice, please select a valid option`n"
    }
} catch {
    Write-Host "`nAn error occurred: $_"
}
