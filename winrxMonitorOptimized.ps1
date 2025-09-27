# =============================================================================
# WINRX MONITOR OPTIMIZED - HIGH-PERFORMANCE DATABASE MONITORING
# =============================================================================
#
# OPTIMIZED APPROACHES FOR LARGE DATABASES:
# 1. Timestamp-based monitoring (only recent changes)
# 2. Batch processing with pagination
# 3. Parallel table processing
# 4. Memory-efficient data structures
# 5. Smart change detection
#
# USAGE:
# .\winrxMonitorOptimized.ps1 -Mode "Timestamp" -Hours 1
# .\winrxMonitorOptimized.ps1 -Mode "Batch" -BatchSize 1000
# .\winrxMonitorOptimized.ps1 -Mode "Parallel" -MaxThreads 4
#
# =============================================================================

param(
    [string]$Mode = "Timestamp", # Timestamp, Batch, Parallel, Hybrid
    [int]$Hours = 1,             # For timestamp mode
    [int]$BatchSize = 1000,      # For batch mode
    [int]$MaxThreads = 4,        # For parallel mode
    [int]$CheckInterval = 30,    # Seconds between checks
    [switch]$EnableLogging = $false
)

# Database connection
$server = "192.168.29.19,1433\SQLEXPRESS"
$username = "sa"
$password = "dexter"
$database = "winrxProsper"
$connectionString = "Server=$server;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=true;Connection Timeout=30;"

# Table configuration with timestamp columns
$TableConfig = @{
    "Appointment" = @{
        PrimaryKey = "AppID"
        TimestampColumn = "AppDateTime"
        Columns = @("AppDateTime", "Pharmacist", "AddUser", "CustomerPHN", "CustomerName", "CustomerAddress", "CustomerPhone", "AppNote", "AppCreatedDateTime")
    }
    "CALLBACK" = @{
        PrimaryKey = "CBID"
        TimestampColumn = "AddDatetime"
        Columns = @("CBDATE", "CBSURNAME", "CBGIVEN", "CBDRUG", "CBNOTE", "CBPHONE", "CBRXNUM", "CBPREV", "CBUSER", "AddDatetime", "AddUsername", "UpdateUsername", "UpdateDatetime", "CBCOMID")
    }
    "CHANGES" = @{
        PrimaryKey = "CGID"
        TimestampColumn = "AddDatetime"
        Columns = @("CGNUM", "CGLIM", "CGQTY", "CGBR", "CGDEA", "CGDRLAST", "CGDR1ST", "CGDATE", "CGUSER", "CGSIG", "CGMSG", "CGDRCOLL", "CGACT", "AddDatetime", "AddUsername", "UpdateUsername", "UpdateDatetime", "CGDRUG", "CGDIN")
    }
    "Communications" = @{
        PrimaryKey = "ID"
        TimestampColumn = "EventDateTime"
        Columns = @("PHN", "Type", "EventDateTime", "Reference", "Resource")
    }
    "DRUG" = @{
        PrimaryKey = "DGDIN"
        TimestampColumn = "AddDatetime"
        Columns = @("DGDESC", "DGUM", "DGTYPE", "DGQ1", "DGQ2", "DGQ3", "DGC1", "DGC2", "DGC3", "DGSHELF", "DGINVNO", "DGGEN1", "DGGEN2", "DGDATE", "DGHAS1", "DGHAS2", "DGHAS3", "DGSUPPLIER", "DGLINE1", "DGLINE2", "DGLINE3", "DGORDER1", "DGORDER2", "DGORDER3", "DGMKUP", "DGINVNO2", "DGINVNO3", "DGTRADE", "DGSIG", "DGEXPIRE", "DG2OLD", "DGWARN", "DGU1", "DGU2", "DGU3", "DGU4", "DGU5", "DGU6", "DGU7", "DGU8", "DGU9", "DGU10", "DGU11", "DGU12", "DGUMON", "DGPACK", "DGSIGCODE", "DGCOUNSEL", "DGMSP", "DGDAYRATE", "DGWKRATE", "DGMONRATE", "DGPST", "DGGST", "DGGRACE", "DGLCADIN", "DGLCACOST", "DGPACMED", "DGPRICE", "DGTXMKUP", "DGBIN", "DGUSED", "DGUSE", "DGUPC", "DGCATEGORY", "AddDatetime")
    }
    "PRESETMESSAGES" = @{
        PrimaryKey = "ID"
        TimestampColumn = "ID"
        Columns = @("MSGDESC", "MSGTEXT")
    }
    "WINMAIL_RECEIVED" = @{
        PrimaryKey = "ID"
        TimestampColumn = "EntryDate"
        Columns = @("EntryDate", "Message", "Guid", "NAME", "FAXNUM", "PAGES", "FILENAME", "Note", "SRFaxID", "SRFaxFileName", "Unread")
    }
}

# Global variables for tracking
$global:LastCheckTimes = @{}
$global:ChangeLog = @()

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    
    if ($EnableLogging) {
        Add-Content -Path "monitor.log" -Value $logMessage
    }
    
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    
    Write-Host $logMessage -ForegroundColor $color
}

function Get-TimestampQuery {
    param([string]$TableName, [hashtable]$Config, [int]$Hours)
    
    $columns = $Config.Columns -join ", "
    $timestampCol = $Config.TimestampColumn
    $primaryKey = $Config.PrimaryKey
    
    # Handle tables without proper timestamp columns
    if ($timestampCol -eq "ID" -or $timestampCol -eq $primaryKey) {
        return @"
SELECT TOP 1000 [$primaryKey], $columns 
FROM [$TableName] 
ORDER BY [$primaryKey] DESC
"@
    } else {
        return @"
SELECT TOP 10000 [$primaryKey], $columns 
FROM [$TableName] 
WHERE [$timestampCol] >= DATEADD(hour, -$Hours, GETDATE())
ORDER BY [$timestampCol] DESC
"@
    }
}

function Get-BatchQuery {
    param([string]$TableName, [hashtable]$Config, [int]$BatchSize, [int]$Offset)
    
    $columns = $Config.Columns -join ", "
    $primaryKey = $Config.PrimaryKey
    
    return @"
SELECT [$primaryKey], $columns 
FROM [$TableName] 
ORDER BY [$primaryKey] 
OFFSET $Offset ROWS 
FETCH NEXT $BatchSize ROWS ONLY
"@
}

function Get-ChangeCountQuery {
    param([string]$TableName, [hashtable]$Config, [int]$Hours)
    
    $timestampCol = $Config.TimestampColumn
    
    # Handle tables without proper timestamp columns
    if ($timestampCol -eq "ID" -or $timestampCol -eq $Config.PrimaryKey) {
        return @"
SELECT COUNT(*) as ChangeCount
FROM [$TableName]
"@
    } else {
        return @"
SELECT COUNT(*) as ChangeCount
FROM [$TableName] 
WHERE [$timestampCol] >= DATEADD(hour, -$Hours, GETDATE())
"@
    }
}

function Invoke-OptimizedQuery {
    param([string]$Query, [string]$TableName)
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        
        $command = New-Object System.Data.SqlClient.SqlCommand($Query, $connection)
        
        $reader = $command.ExecuteReader()
        $results = @()
        
        while ($reader.Read()) {
            $row = @{}
            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $fieldName = $reader.GetName($i)
                $row[$fieldName] = if ($reader.IsDBNull($i)) { "" } else { $reader.GetValue($i).ToString() }
            }
            $results += $row
        }
        
        $reader.Close()
        $connection.Close()
        
        return $results
    }
    catch {
        Write-Log "Error querying $TableName`: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Start-TimestampMonitoring {
    Write-Log "Starting TIMESTAMP-based monitoring (last $Hours hours)" "INFO"
    
    foreach ($tableName in $TableConfig.Keys) {
        $config = $TableConfig[$tableName]
        
        # First, check if there are any recent changes
        $countQuery = Get-ChangeCountQuery $tableName $config $Hours
        $countResult = Invoke-OptimizedQuery $countQuery $tableName
        $changeCount = if ($countResult -and $countResult.Count -gt 0) { $countResult[0].ChangeCount } else { 0 }
        
        if ($changeCount -gt 0) {
            Write-Log "Found $changeCount recent changes in $tableName" "SUCCESS"
            
            # Get the actual changes
            $query = Get-TimestampQuery $tableName $config $Hours
            $changes = Invoke-OptimizedQuery $query $tableName
            
            foreach ($change in $changes) {
                $global:ChangeLog += @{
                    Table = $tableName
                    RecordID = $change[$config.PrimaryKey]
                    ChangeType = "RECENT"
                    Timestamp = $change[$config.TimestampColumn]
                    Data = $change
                }
            }
        }
        else {
            Write-Log "No recent changes in $tableName" "INFO"
        }
    }
}

function Start-BatchMonitoring {
    Write-Log "Starting BATCH-based monitoring (batch size: $BatchSize)" "INFO"
    
    foreach ($tableName in $TableConfig.Keys) {
        $config = $TableConfig[$tableName]
        $offset = 0
        $hasMoreData = $true
        
        while ($hasMoreData) {
            $query = Get-BatchQuery $tableName $config $BatchSize $offset
            $batch = Invoke-OptimizedQuery $query $tableName
            
            if ($batch.Count -lt $BatchSize) {
                $hasMoreData = $false
            }
            
            Write-Log "Processed batch $($offset + 1) for $tableName (${batch.Count} records)" "INFO"
            $offset += $BatchSize
            
            # Process batch here (compare with previous data, etc.)
            Start-Sleep -Milliseconds 100 # Small delay to prevent overwhelming
        }
    }
}

function Start-ParallelMonitoring {
    Write-Log "Starting PARALLEL monitoring (max threads: $MaxThreads)" "INFO"
    
    $jobs = @()
    
    foreach ($tableName in $TableConfig.Keys) {
        $config = $TableConfig[$tableName]
        
        $job = Start-Job -ScriptBlock {
            param($TableName, $Config, $ConnectionString, $Hours)
            
            # Job script to monitor individual table
            $query = @"
SELECT TOP 1000 [$($Config.PrimaryKey)], $($Config.Columns -join ", ")
FROM [$TableName] 
WHERE [$($Config.TimestampColumn)] >= DATEADD(hour, -$Hours, GETDATE())
ORDER BY [$($Config.TimestampColumn)] DESC
"@
            
            try {
                $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
                $connection.Open()
                
                $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
                $reader = $command.ExecuteReader()
                
                $results = @()
                while ($reader.Read()) {
                    $row = @{}
                    for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                        $fieldName = $reader.GetName($i)
                        $row[$fieldName] = if ($reader.IsDBNull($i)) { "" } else { $reader.GetValue($i).ToString() }
                    }
                    $results += $row
                }
                
                $reader.Close()
                $connection.Close()
                
                return @{
                    Table = $TableName
                    RecordCount = $results.Count
                    Data = $results
                }
            }
            catch {
                return @{
                    Table = $TableName
                    Error = $_.Exception.Message
                }
            }
        } -ArgumentList $tableName, $config, $connectionString, $Hours
        
        $jobs += $job
    }
    
    # Wait for all jobs to complete
    $jobs | Wait-Job | Out-Null
    
    # Collect results
    foreach ($job in $jobs) {
        $result = Receive-Job $job
        if ($result.Error) {
            Write-Log "Error in $($result.Table): $($result.Error)" "ERROR"
        } else {
            Write-Log "Completed $($result.Table): $($result.RecordCount) records" "SUCCESS"
        }
        Remove-Job $job
    }
}

function Start-HybridMonitoring {
    Write-Log "Starting HYBRID monitoring (timestamp + parallel)" "INFO"
    
    # Use parallel processing for timestamp-based monitoring
    Start-ParallelMonitoring
}

# Main execution
try {
    Write-Log "Starting optimized database monitoring..." "INFO"
    Write-Log "Mode: $Mode, Interval: $CheckInterval seconds" "INFO"
    
    while ($true) {
        
        switch ($Mode.ToLower()) {
            "timestamp" { Start-TimestampMonitoring }
            "batch" { Start-BatchMonitoring }
            "parallel" { Start-ParallelMonitoring }
            "hybrid" { Start-HybridMonitoring }
            default { 
                Write-Log "Unknown mode: $Mode. Using timestamp mode." "WARN"
                Start-TimestampMonitoring 
            }
        }
        
        
        Write-Log "Monitoring cycle completed in ${duration:F2} seconds" "SUCCESS"
        Write-Log "Found $($global:ChangeLog.Count) total changes" "INFO"
        
        # Display recent changes
        if ($global:ChangeLog.Count -gt 0) {
            Write-Log "Recent changes:" "INFO"
            $global:ChangeLog | Select-Object -Last 5 | ForEach-Object {
                Write-Log "  $($_.Table): $($_.RecordID) - $($_.ChangeType)" "INFO"
            }
        }
        
        Write-Log "Waiting $CheckInterval seconds before next check..." "INFO"
        Start-Sleep $CheckInterval
    }
}
catch {
    Write-Log "Fatal error: $($_.Exception.Message)" "ERROR"
}
finally {
    Write-Log "Monitoring stopped." "INFO"
}
