param(
    [hashtable]$TableConfig = @{
        "b" = "id"
        "c" = "rxid"
    },
    [int]$CheckInterval = 5
)

# Database connection
$server = "192.168.29.19,1433\SQLEXPRESS"
$username = "sa"
$password = "dexter"
$database = "medidozeProsper"

# Connection string
$connectionString = "Server=$server;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=true;"

# Check for changes in a single table
function Check-TableChanges {
    param(
        [string]$TableName,
        [string]$ColumnName,
        [hashtable]$PreviousData
    )
    
    $connection = $null
    $reader = $null
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
        $connection.Open()
        
        # Use different queries based on table structure
        if ($TableName -eq "b") {
            $query = "SELECT [$ColumnName], name, age FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        elseif ($TableName -eq "c") {
            $query = "SELECT [$ColumnName], school, class FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        else {
            # Default query for other tables
            $query = "SELECT [$ColumnName] FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        
        $command = New-Object System.Data.SqlClient.SqlCommand $query, $connection
        $reader = $command.ExecuteReader()
        
        $currentData = @{}
        $updatedIds = @()
        $newIds = @()
        
        while ($reader.Read()) {
            $id = $reader.GetValue(0)
            
            # Build row data based on table structure
            if ($TableName -eq "b") {
                $name = if ($reader.IsDBNull(1)) { "" } else { $reader.GetString(1) }
                $age = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                
                $rowData = @{
                    name = $name
                    age = $age
                }
            }
            elseif ($TableName -eq "c") {
                $school = if ($reader.IsDBNull(1)) { "" } else { $reader.GetString(1) }
                $class = if ($reader.IsDBNull(2)) { "" } else { $reader.GetString(2) }
                
                $rowData = @{
                    school = $school
                    class = $class
                }
            }
            else {
                $rowData = @{}
            }
            
            $currentData[$id.ToString()] = $rowData
            
            # Check if this is a new row
            if (-not $PreviousData.ContainsKey($id.ToString())) {
                $newIds += $id
            }
            # Check if this row was updated
            else {
                $previousRow = $PreviousData[$id.ToString()]
                $hasChanges = $false
                
                # Compare based on table structure
                if ($TableName -eq "b") {
                    if ($previousRow.name -ne $name -or $previousRow.age -ne $age) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "c") {
                    if ($previousRow.school -ne $school -or $previousRow.class -ne $class) {
                        $hasChanges = $true
                    }
                }
                
                if ($hasChanges) {
                    $updatedIds += $id
                }
            }
        }
        
        # Check for deleted rows
        $deletedIds = @()
        foreach ($id in $PreviousData.Keys) {
            if (-not $currentData.ContainsKey($id)) {
                $deletedIds += [int]$id
            }
        }
        
        return @{
            Success = $true
            NewIds = $newIds
            UpdatedIds = $updatedIds
            DeletedIds = $deletedIds
            CurrentData = $currentData
        }
    }
    catch {
        Write-Error "Database error for table [$TableName]: $_"
        return @{
            Success = $false
            NewIds = @()
            UpdatedIds = @()
            DeletedIds = @()
            CurrentData = $PreviousData
        }
    }
    finally {
        if ($reader -and -not $reader.IsClosed) {
            $reader.Close()
        }
        if ($connection -and $connection.State -eq 'Open') {
            $connection.Close()
        }
    }
}

# Check all tables for changes
function Check-AllTables {
    param([hashtable]$AllPreviousData)
    
    $allResults = @{}
    
    foreach ($tableName in $TableConfig.Keys) {
        $columnName = $TableConfig[$tableName]
        $previousData = if ($AllPreviousData.ContainsKey($tableName)) { $AllPreviousData[$tableName] } else { @{} }
        $result = Check-TableChanges $tableName $columnName $previousData
        $allResults[$tableName] = $result
    }
    
    return $allResults
}

# Main execution
try {
    Write-Host "Monitoring tables with their respective column names:"
    foreach ($tableName in $TableConfig.Keys) {
        Write-Host "  [$tableName] -> [$($TableConfig[$tableName])]"
    }
    Write-Host "Check interval: $CheckInterval seconds"
    Write-Host "Press Ctrl+C to stop"
    Write-Host ""
    
    # Initialize previous data for all tables
    $allPreviousData = @{}
    foreach ($tableName in $TableConfig.Keys) {
        $allPreviousData[$tableName] = @{}
    }
    
    while ($true) {
        try {
            $allResults = Check-AllTables $allPreviousData
            
            $hasAnyChanges = $false
            
            foreach ($tableName in $TableConfig.Keys) {
                $columnName = $TableConfig[$tableName]
                $result = $allResults[$tableName]
                
                if ($result -and $result.Success) {
                    $hasChanges = $false
                    $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    
                    # Check for new rows
                    if ($result.NewIds -and $result.NewIds.Count -gt 0) {
                        foreach ($id in $result.NewIds) {
                            Write-Host "table: $tableName, operation: NEW, $columnName`: $id" -ForegroundColor Green
                            $hasChanges = $true
                            $hasAnyChanges = $true
                        }
                    }
                    
                    # Check for updated rows
                    if ($result.UpdatedIds -and $result.UpdatedIds.Count -gt 0) {
                        foreach ($id in $result.UpdatedIds) {
                            Write-Host "table: $tableName, operation: UPDATED, $columnName`: $id" -ForegroundColor Yellow
                            $hasChanges = $true
                            $hasAnyChanges = $true
                        }
                    }
                    
                    # Check for deleted rows
                    if ($result.DeletedIds -and $result.DeletedIds.Count -gt 0) {
                        foreach ($id in $result.DeletedIds) {
                            Write-Host "table: $tableName, operation: DELETED, $columnName`: $id" -ForegroundColor Red
                            $hasChanges = $true
                            $hasAnyChanges = $true
                        }
                    }
                    
                    # Update previous data for this table
                    if ($result.CurrentData) {
                        $allPreviousData[$tableName] = $result.CurrentData
                    }
                }
            }
            
            if ($hasAnyChanges) {
                Write-Host "---" -ForegroundColor Gray
            }
        }
        catch {
            Write-Error "Error in main loop: $_"
        }
        
        Start-Sleep $CheckInterval
    }
}
catch {
    Write-Error "Script error: $_"
    exit 1
}
