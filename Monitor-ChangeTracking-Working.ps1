# Monitor-ChangeTracking-Working.ps1
# Efficient change monitoring using SQL Server Change Tracking

param(
    [string]$Server = "192.168.29.19,1433\SQLEXPRESS",
    [string]$Database = "winrxProsper", 
    [string]$Username = "sa",
    [string]$Password = "dexter",
    [int]$CheckInterval = 2,
    [switch]$ShowDetails = $false,
    [switch]$ResetBaseline = $false
)

# Database connection
$connectionString = "Server=$server;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=true;"

# Tables to monitor with their primary key columns
$tableConfig = @{
    "Appointment" = "AppID"
    "CALLBACK" = "CBID"
    "CHANGES" = "CGID"
    "CHGDRUG" = "CHGDGID"
    "Communications" = "ID"
    "DOCUMENTS" = "ID"
    "DRUG" = "DGDIN"
    "ERX" = "XKEY"
    "PACMED" = "Id"
    "PATIENT" = "PANUM"
    "REFILL" = "REFILLID"
    "RX" = "RXNUM"
    "TXNS" = "TXNSID"
}

# Store last synchronization versions for each table
$lastSyncVersions = @{}

function Get-ChangeTrackingVersion {
    $query = "SELECT CHANGE_TRACKING_CURRENT_VERSION() as CurrentVersion"
    $result = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query
    return $result.CurrentVersion
}

function Get-TableChanges {
    param(
        [string]$TableName,
        [string]$PrimaryKeyColumn,
        [bigint]$LastSyncVersion
    )
    
    $query = @"
DECLARE @last_sync_version bigint = $LastSyncVersion;
SELECT 
    CT.SYS_CHANGE_OPERATION,
    CT.SYS_CHANGE_VERSION,
    CT.SYS_CHANGE_CREATION_VERSION,
    CT.SYS_CHANGE_COLUMNS,
    CT.$PrimaryKeyColumn
FROM CHANGETABLE(CHANGES [$TableName], @last_sync_version) AS CT
ORDER BY CT.SYS_CHANGE_VERSION;
"@
    
    try {
        $result = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query
        if ($result -and $result.Count -gt 0) {
            Write-Host "[DEBUG] Query returned $($result.Count) rows for $TableName" -ForegroundColor DarkYellow
            foreach ($row in $result) {
                Write-Host "[DEBUG]   Operation: $($row.SYS_CHANGE_OPERATION), Version: $($row.SYS_CHANGE_VERSION), PK: $($row.$PrimaryKeyColumn)" -ForegroundColor DarkYellow
            }
        } else {
            Write-Host "[DEBUG] No results returned for $TableName from version $LastSyncVersion" -ForegroundColor DarkYellow
        }
        return $result
    }
    catch {
        Write-Warning "Failed to get changes for table $TableName`: $_"
        return @()
    }
}

function Get-ChangeTrackingColumns {
    param(
        [string]$TableName,
        [object]$ChangeColumns
    )
    
    if ($ChangeColumns -eq $null -or $ChangeColumns -eq [DBNull]::Value) {
        return "All columns"
    }
    
    return "Columns changed (CHANGED_COLUMNS not supported in this SQL Server version)"
}

function Get-FullRowData {
    param(
        [string]$TableName,
        [string]$PrimaryKeyColumn,
        [object]$PrimaryKeyValue
    )
    
    $query = "SELECT * FROM [$TableName] WHERE [$PrimaryKeyColumn] = '$PrimaryKeyValue'"
    
    try {
        $result = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query
        return $result
    }
    catch {
        Write-Warning "Failed to get full row data for $TableName.$PrimaryKeyColumn = $PrimaryKeyValue`: $_"
        return $null
    }
}

function Show-ChangeDetails {
    param(
        [string]$TableName,
        [string]$Operation,
        [object]$PrimaryKeyValue,
        [string]$ChangedColumns,
        [object]$RowData,
        [bigint]$ChangeVersion
    )
    
    $color = switch ($Operation) {
        "I" { "Green" }
        "U" { "Yellow" }
        "D" { "Red" }
        default { "White" }
    }
    
    $operationText = switch ($Operation) {
        "I" { "INSERT" }
        "U" { "UPDATE" }
        "D" { "DELETE" }
        default { $Operation }
    }
    
    Write-Host "=== $operationText DETECTED ===" -ForegroundColor $color
    Write-Host "Table: $TableName" -ForegroundColor $color
    Write-Host "Primary Key: $PrimaryKeyValue" -ForegroundColor $color
    Write-Host "Change Version: $ChangeVersion" -ForegroundColor Cyan
    
    if ($ChangedColumns -and $ChangedColumns -ne "All columns") {
        Write-Host "Changed Columns: $ChangedColumns" -ForegroundColor Cyan
    }
    
    if ($ShowDetails -and $RowData) {
        Write-Host "Row Data:" -ForegroundColor Cyan
        foreach ($property in $RowData.PSObject.Properties) {
            Write-Host "  $($property.Name) = $($property.Value)" -ForegroundColor White
        }
    }
    
    Write-Host "=========================" -ForegroundColor $color
}

# Initialize last sync versions
Write-Host "Initializing Change Tracking Monitor..." -ForegroundColor Green
Write-Host "Database: $Database" -ForegroundColor Cyan
Write-Host "Server: $Server" -ForegroundColor Cyan
Write-Host "Check Interval: $CheckInterval seconds" -ForegroundColor Cyan

if ($ResetBaseline) {
    Write-Host "RESET BASELINE mode - starting fresh" -ForegroundColor Yellow
    foreach ($tableName in $tableConfig.Keys) {
        $lastSyncVersions[$tableName] = 0
    }
} else {
    $currentVersion = Get-ChangeTrackingVersion
    Write-Host "Current Change Tracking Version: $currentVersion" -ForegroundColor Cyan
    Write-Host "Starting monitoring from version: $currentVersion (will detect changes after this point)" -ForegroundColor Yellow
    
    foreach ($tableName in $tableConfig.Keys) {
        $lastSyncVersions[$tableName] = $currentVersion
        Write-Host "  $tableName -> Starting from version: $currentVersion" -ForegroundColor Gray
    }
    
    Write-Host "Waiting 3 seconds to ensure we capture any immediate changes..." -ForegroundColor Yellow
    Start-Sleep 3
}

Write-Host "`nChange Tracking Monitor Started" -ForegroundColor Green
Write-Host "Monitoring $(($tableConfig.Keys).Count) tables:" -ForegroundColor Yellow
foreach ($tableName in ($tableConfig.Keys | Sort-Object)) {
    Write-Host "  - $tableName" -ForegroundColor Gray
}

Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Main monitoring loop
try {
    while ($true) {
        $hasAnyChanges = $false
        $totalChanges = 0
        
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Checking for changes..." -ForegroundColor Gray
        
        $currentVersion = Get-ChangeTrackingVersion
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Current database version: $currentVersion" -ForegroundColor DarkGray
        
        foreach ($tableName in ($tableConfig.Keys | Sort-Object)) {
            $primaryKeyColumn = $tableConfig[$tableName]
            $lastSyncVersion = $lastSyncVersions[$tableName]
            
            try {
                Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Checking $tableName from version: $lastSyncVersion" -ForegroundColor DarkGray
                
                $changes = Get-TableChanges -TableName $tableName -PrimaryKeyColumn $primaryKeyColumn -LastSyncVersion $lastSyncVersion
                
                if ($changes -and $changes.Count -gt 0) {
                    Write-Host "[DEBUG] Found $($changes.Count) changes for $tableName" -ForegroundColor DarkYellow
                    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Found $($changes.Count) changes in table: $tableName" -ForegroundColor Magenta
                    $totalChanges += $changes.Count
                    
                    $highestVersion = $lastSyncVersion
                    
                    foreach ($change in $changes) {
                        $operation = $change.SYS_CHANGE_OPERATION
                        $primaryKeyValue = $change.$primaryKeyColumn
                        $changeVersion = $change.SYS_CHANGE_VERSION
                        
                        if ($changeVersion -gt $highestVersion) {
                            $highestVersion = $changeVersion
                        }
                        
                        $changeColumnsData = $change.SYS_CHANGE_COLUMNS
                        $changedColumns = Get-ChangeTrackingColumns -TableName $tableName -ChangeColumns $changeColumnsData
                        
                        $rowData = $null
                        if ($ShowDetails -and $operation -ne "D") {
                            $rowData = Get-FullRowData -TableName $tableName -PrimaryKeyColumn $primaryKeyColumn -PrimaryKeyValue $primaryKeyValue
                        }
                        
                        Show-ChangeDetails -TableName $tableName -Operation $operation -PrimaryKeyValue $primaryKeyValue -ChangedColumns $changedColumns -RowData $rowData -ChangeVersion $changeVersion
                        
                        $hasAnyChanges = $true
                    }
                    
                    $lastSyncVersions[$tableName] = $highestVersion
                    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Updated $tableName sync version to: $highestVersion" -ForegroundColor DarkGreen
                } else {
                    Write-Host "[DEBUG] No changes found for $tableName from version $lastSyncVersion" -ForegroundColor DarkYellow
                }
            }
            catch {
                Write-Error "Error checking table $tableName`: $_"
            }
        }
        
        if (-not $hasAnyChanges) {
            Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] No changes detected" -ForegroundColor Gray
        } else {
            Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Processed $totalChanges total changes" -ForegroundColor Green
            Write-Host "---" -ForegroundColor Gray
        }
        
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Waiting $CheckInterval seconds..." -ForegroundColor Gray
        Start-Sleep $CheckInterval
    }
}
catch {
    Write-Error "Monitoring error: $_"
}
finally {
    Write-Host "`nChange Tracking Monitor stopped." -ForegroundColor Yellow
    Write-Host "Final sync versions:" -ForegroundColor Cyan
    foreach ($tableName in ($tableConfig.Keys | Sort-Object)) {
        Write-Host "  $tableName -> Version: $($lastSyncVersions[$tableName])" -ForegroundColor Gray
    }
}
