# cron job to fetch data from table
# command to run .\scr.ps1
[CmdletBinding()]
param(
  [string]$Server          = ".\SQLEXPRESS",
  [string]$Database        = "medidozeProsper",
  [string]$SchemaName      = "dbo",
  [string]$TableName       = "b",
  [int]   $IntervalSeconds = 5,
  [int]   $Top             = 0,        # 0 = all rows
  [string]$OrderBy         = "[id]",   # change if needed
  [switch]$UseSqlAuth      = $false,
  [string]$Username,
  [string]$Password
)

$ErrorActionPreference = 'Stop'

# --- locate sqlcmd.exe (no null-conditional used) ---
$cmd = $null
$gc = Get-Command sqlcmd -ErrorAction SilentlyContinue
if ($gc) { $cmd = $gc.Source }

if (-not $cmd) {
  $candidates = @(
    "$env:ProgramFiles\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
    "$env:ProgramFiles\Microsoft SQL Server\Client SDK\ODBC\160\Tools\Binn\sqlcmd.exe",
    "$env:ProgramFiles\Microsoft SQL Server\150\Tools\Binn\sqlcmd.exe",
    "$env:ProgramFiles\Microsoft SQL Server\140\Tools\Binn\sqlcmd.exe"
  )
  foreach ($p in $candidates) { if (Test-Path $p) { $cmd = $p; break } }
}

if (-not $cmd) {
  throw "sqlcmd.exe not found. Install SQL Server Command Line Utilities or add sqlcmd to PATH."
}

# --- query text ---
$selectTop = if ($Top -gt 0) { "TOP ($Top) " } else { "" }
$q = "SET NOCOUNT ON; SELECT $selectTop * FROM [$SchemaName].[$TableName] WITH (NOLOCK) ORDER BY $OrderBy;"

# --- auth args ---
$authArgs = @()
if ($UseSqlAuth) {
  if (-not $Username -or -not $Password) { throw "Provide -Username and -Password with -UseSqlAuth." }
  $authArgs += @("-U", $Username, "-P", $Password)
} else {
  $authArgs += @("-E")  # Windows auth
}

Write-Host ("Watching [{0}].[{1}] in DB [{2}] - press Ctrl+C to stop." -f $SchemaName,$TableName,$Database) -ForegroundColor Cyan

while ($true) {
  try {
    Clear-Host
    $stamp = (Get-Date).ToString("s")
    Write-Host ("[" + $stamp + "] " + $SchemaName + "." + $TableName) -ForegroundColor Cyan

    # -W trims spaces, -s sets a clear separator
    & "$cmd" -S $Server -d $Database -Q $q -W -s " | " @authArgs
  }
  catch {
    Write-Host ("Poll failed: " + $_.Exception.Message) -ForegroundColor Red
  }

  Start-Sleep -Seconds $IntervalSeconds
}
