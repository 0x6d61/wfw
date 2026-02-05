#Requires -Version 5.1
<#
.SYNOPSIS
    Write output in appropriate format

.DESCRIPTION
    Control output based on --json, --quiet, --verbose options

.PARAMETER Data
    Data to output

.PARAMETER Options
    Global options

.PARAMETER Message
    Text message (for non-JSON output)

.PARAMETER Level
    Log level (Info, Warning, Error, Verbose)
#>
function Write-WfwOutput {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object]$Data,

        [Parameter()]
        [hashtable]$Options = @{},

        [Parameter()]
        [string]$Message,

        [Parameter()]
        [ValidateSet("Info", "Warning", "Error", "Verbose", "Success")]
        [string]$Level = "Info"
    )

    # Quiet mode suppresses non-errors
    if ($Options.Quiet -and $Level -notin @("Error")) {
        return
    }

    # Verbose messages only in verbose mode
    if ($Level -eq "Verbose" -and -not $Options.Verbose) {
        return
    }

    # JSON output
    if ($Options.Json -and $Data) {
        $Data | ConvertTo-Json -Depth 10
        return
    }

    # Text output
    if ($Message) {
        switch ($Level) {
            "Info" { Write-Host $Message }
            "Warning" { Write-Host $Message -ForegroundColor Yellow }
            "Error" { Write-Host $Message -ForegroundColor Red }
            "Verbose" { Write-Host $Message -ForegroundColor Gray }
            "Success" { Write-Host $Message -ForegroundColor Green }
        }
    }
}
