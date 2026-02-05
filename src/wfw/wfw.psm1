#Requires -Version 5.1

# Module root directory
$ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load Private functions
$PrivatePath = Join-Path $ModuleRoot "Private"
if (Test-Path $PrivatePath) {
    Get-ChildItem -Path $PrivatePath -Filter "*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}

# Load Public functions
$PublicPath = Join-Path $ModuleRoot "Public"
if (Test-Path $PublicPath) {
    Get-ChildItem -Path $PublicPath -Filter "*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}

# Module shared variables
$script:WfwGroupName = "FWCLI"
$script:WfwVersion = "0.1.0"

# Exit codes
$script:ExitCodes = @{
    Success          = 0
    GeneralError     = 1
    ArgumentError    = 2
    PermissionDenied = 3
    NotFound         = 4
    Conflict         = 5
}
