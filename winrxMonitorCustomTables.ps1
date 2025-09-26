param(
    [hashtable]$TableConfig = @{
        "Appointment" = "AppID"
    },
    [int]$CheckInterval = 5
)

# Database connection
$server = "192.168.29.19,1433\SQLEXPRESS"
$username = "sa"
$password = "dexter"
$database = "winrxProsper"

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
        if ($TableName -eq "Appointment") {
            $query = "SELECT [$ColumnName], AppDateTime, Pharmacist, AddUser, CustomerPHN, CustomerName, CustomerAddress, CustomerPhone, AppNote, AppCreatedDateTime FROM [$TableName] ORDER BY [$ColumnName] ASC"
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
        $updatedDetails = @{}
        
        while ($reader.Read()) {
            $id = $reader.GetValue(0)
            
            # Build row data based on table structure
            if ($TableName -eq "Appointment") {
                $appDateTime = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $pharmacist = if ($reader.IsDBNull(2)) { "" } else { $reader.GetString(2) }
                $addUser = if ($reader.IsDBNull(3)) { "" } else { $reader.GetString(3) }
                $customerPHN = if ($reader.IsDBNull(4)) { "" } else { $reader.GetString(4) }
                $customerName = if ($reader.IsDBNull(5)) { "" } else { $reader.GetString(5) }
                $customerAddress = if ($reader.IsDBNull(6)) { "" } else { $reader.GetString(6) }
                $customerPhone = if ($reader.IsDBNull(7)) { "" } else { $reader.GetString(7) }
                $appNote = if ($reader.IsDBNull(8)) { "" } else { $reader.GetString(8) }
                $appCreatedDateTime = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                
                $rowData = @{
                    AppDateTime = $appDateTime
                    Pharmacist = $pharmacist
                    AddUser = $addUser
                    CustomerPHN = $customerPHN
                    CustomerName = $customerName
                    CustomerAddress = $customerAddress
                    CustomerPhone = $customerPhone
                    AppNote = $appNote
                    AppCreatedDateTime = $appCreatedDateTime
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
                if ($TableName -eq "Appointment") {
                    if ($previousRow.AppDateTime -ne $appDateTime -or 
                        $previousRow.Pharmacist -ne $pharmacist -or 
                        $previousRow.AddUser -ne $addUser -or 
                        $previousRow.CustomerPHN -ne $customerPHN -or 
                        $previousRow.CustomerName -ne $customerName -or 
                        $previousRow.CustomerAddress -ne $customerAddress -or 
                        $previousRow.CustomerPhone -ne $customerPhone -or 
                        $previousRow.AppNote -ne $appNote -or 
                        $previousRow.AppCreatedDateTime -ne $appCreatedDateTime) {
                        $hasChanges = $true
                    }
                }
                
                if ($hasChanges) {
                    $updatedIds += $id
                    $updatedDetails[$id.ToString()] = @{
                        Previous = $previousRow
                        Current = $rowData
                    }
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
            UpdatedDetails = $updatedDetails
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
            UpdatedDetails = @{}
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
                            
                            # Show detailed changes if available
                            if ($result.UpdatedDetails -and $result.UpdatedDetails.ContainsKey($id.ToString())) {
                                $details = $result.UpdatedDetails[$id.ToString()]
                                $previous = $details.Previous
                                $current = $details.Current
                                
                                Write-Host "  Changes:" -ForegroundColor Cyan
                                foreach ($field in $current.Keys) {
                                    $oldValue = if ($previous.ContainsKey($field)) { $previous[$field] } else { "NULL" }
                                    $newValue = $current[$field]
                                    if ($oldValue -ne $newValue) {
                                        Write-Host "    $field`: '$oldValue' -> '$newValue'" -ForegroundColor White
                                    }
                                }
                            }
                            
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
