param(
    [hashtable]$TableConfig = @{
        "Appointment" = "AppID"
        "Communications" = "ID"
        "DRUG" = "DGDIN"
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
        elseif ($TableName -eq "Communications") {
            $query = "SELECT [$ColumnName], PHN, Type, EventDateTime, Reference, Resource FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        elseif ($TableName -eq "DRUG") {
            $query = "SELECT [$ColumnName], DGDESC, DGUM, DGTYPE, DGQ1, DGQ2, DGQ3, DGC1, DGC2, DGC3, DGSHELF, DGINVNO, DGGEN1, DGGEN2, DGDATE, DGHAS1, DGHAS2, DGHAS3, DGSUPPLIER, DGLINE1, DGLINE2, DGLINE3, DGORDER1, DGORDER2, DGORDER3, DGMKUP, DGINVNO2, DGINVNO3, DGTRADE, DGSIG, DGEXPIRE, DG2OLD, DGWARN, DGU1, DGU2, DGU3, DGU4, DGU5, DGU6, DGU7, DGU8, DGU9, DGU10, DGU11, DGU12, DGUMON, DGPACK, DGSIGCODE, DGCOUNSEL, DGMSP, DGDAYRATE, DGWKRATE, DGMONRATE, DGPST, DGGST, DGGRACE, DGLCADIN, DGLCACOST, DGPACMED, DGPRICE, DGTXMKUP, DGBIN, DGUSED, DGUSE, DGUPC, DGCATEGORY, AddDatetime FROM [$TableName] ORDER BY [$ColumnName] ASC"
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
            elseif ($TableName -eq "Communications") {
                $phn = if ($reader.IsDBNull(1)) { "" } else { $reader.GetString(1) }
                $type = if ($reader.IsDBNull(2)) { "" } else { $reader.GetString(2) }
                $eventDateTime = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $reference = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $resource = if ($reader.IsDBNull(5)) { "" } else { $reader.GetString(5) }
                
                $rowData = @{
                    PHN = $phn
                    Type = $type
                    EventDateTime = $eventDateTime
                    Reference = $reference
                    Resource = $resource
                }
            }
            elseif ($TableName -eq "DRUG") {
                $dgdesc = if ($reader.IsDBNull(1)) { "" } else { $reader.GetString(1) }
                $dgum = if ($reader.IsDBNull(2)) { "" } else { $reader.GetString(2) }
                $dgtype = if ($reader.IsDBNull(3)) { "" } else { $reader.GetString(3) }
                $dgq1 = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $dgq2 = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $dgq3 = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $dgc1 = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $dgc2 = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $dgc3 = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $dgshelf = if ($reader.IsDBNull(10)) { "" } else { $reader.GetString(10) }
                $dginvno = if ($reader.IsDBNull(11)) { "" } else { $reader.GetString(11) }
                $dggen1 = if ($reader.IsDBNull(12)) { "" } else { $reader.GetValue(12).ToString() }
                $dggen2 = if ($reader.IsDBNull(13)) { "" } else { $reader.GetValue(13).ToString() }
                $dgdate = if ($reader.IsDBNull(14)) { "" } else { $reader.GetValue(14).ToString() }
                $dghas1 = if ($reader.IsDBNull(15)) { "" } else { $reader.GetValue(15).ToString() }
                $dghas2 = if ($reader.IsDBNull(16)) { "" } else { $reader.GetValue(16).ToString() }
                $dghas3 = if ($reader.IsDBNull(17)) { "" } else { $reader.GetValue(17).ToString() }
                $dgsupplier = if ($reader.IsDBNull(18)) { "" } else { $reader.GetString(18) }
                $dgline1 = if ($reader.IsDBNull(19)) { "" } else { $reader.GetValue(19).ToString() }
                $dgline2 = if ($reader.IsDBNull(20)) { "" } else { $reader.GetValue(20).ToString() }
                $dgline3 = if ($reader.IsDBNull(21)) { "" } else { $reader.GetValue(21).ToString() }
                $dgorder1 = if ($reader.IsDBNull(22)) { "" } else { $reader.GetValue(22).ToString() }
                $dgorder2 = if ($reader.IsDBNull(23)) { "" } else { $reader.GetValue(23).ToString() }
                $dgorder3 = if ($reader.IsDBNull(24)) { "" } else { $reader.GetValue(24).ToString() }
                $dgmkup = if ($reader.IsDBNull(25)) { "" } else { $reader.GetValue(25).ToString() }
                $dginvno2 = if ($reader.IsDBNull(26)) { "" } else { $reader.GetString(26) }
                $dginvno3 = if ($reader.IsDBNull(27)) { "" } else { $reader.GetString(27) }
                $dgtrade = if ($reader.IsDBNull(28)) { "" } else { $reader.GetString(28) }
                $dgsig = if ($reader.IsDBNull(29)) { "" } else { $reader.GetString(29) }
                $dgexpire = if ($reader.IsDBNull(30)) { "" } else { $reader.GetValue(30).ToString() }
                $dg2old = if ($reader.IsDBNull(31)) { "" } else { $reader.GetValue(31).ToString() }
                $dgwarn = if ($reader.IsDBNull(32)) { "" } else { $reader.GetString(32) }
                $dgu1 = if ($reader.IsDBNull(33)) { "" } else { $reader.GetValue(33).ToString() }
                $dgu2 = if ($reader.IsDBNull(34)) { "" } else { $reader.GetValue(34).ToString() }
                $dgu3 = if ($reader.IsDBNull(35)) { "" } else { $reader.GetValue(35).ToString() }
                $dgu4 = if ($reader.IsDBNull(36)) { "" } else { $reader.GetValue(36).ToString() }
                $dgu5 = if ($reader.IsDBNull(37)) { "" } else { $reader.GetValue(37).ToString() }
                $dgu6 = if ($reader.IsDBNull(38)) { "" } else { $reader.GetValue(38).ToString() }
                $dgu7 = if ($reader.IsDBNull(39)) { "" } else { $reader.GetValue(39).ToString() }
                $dgu8 = if ($reader.IsDBNull(40)) { "" } else { $reader.GetValue(40).ToString() }
                $dgu9 = if ($reader.IsDBNull(41)) { "" } else { $reader.GetValue(41).ToString() }
                $dgu10 = if ($reader.IsDBNull(42)) { "" } else { $reader.GetValue(42).ToString() }
                $dgu11 = if ($reader.IsDBNull(43)) { "" } else { $reader.GetValue(43).ToString() }
                $dgu12 = if ($reader.IsDBNull(44)) { "" } else { $reader.GetValue(44).ToString() }
                $dgumon = if ($reader.IsDBNull(45)) { "" } else { $reader.GetValue(45).ToString() }
                $dgpack = if ($reader.IsDBNull(46)) { "" } else { $reader.GetValue(46).ToString() }
                $dgsigcode = if ($reader.IsDBNull(47)) { "" } else { $reader.GetString(47) }
                $dgcounsel = if ($reader.IsDBNull(48)) { "" } else { $reader.GetString(48) }
                $dgmsp = if ($reader.IsDBNull(49)) { "" } else { $reader.GetValue(49).ToString() }
                $dgdayrate = if ($reader.IsDBNull(50)) { "" } else { $reader.GetValue(50).ToString() }
                $dgwkrate = if ($reader.IsDBNull(51)) { "" } else { $reader.GetValue(51).ToString() }
                $dgmonrate = if ($reader.IsDBNull(52)) { "" } else { $reader.GetValue(52).ToString() }
                $dgpst = if ($reader.IsDBNull(53)) { "" } else { $reader.GetValue(53).ToString() }
                $dggst = if ($reader.IsDBNull(54)) { "" } else { $reader.GetValue(54).ToString() }
                $dggrace = if ($reader.IsDBNull(55)) { "" } else { $reader.GetValue(55).ToString() }
                $dglcadin = if ($reader.IsDBNull(56)) { "" } else { $reader.GetValue(56).ToString() }
                $dglcacost = if ($reader.IsDBNull(57)) { "" } else { $reader.GetValue(57).ToString() }
                $dgpacmed = if ($reader.IsDBNull(58)) { "" } else { $reader.GetString(58) }
                $dgprice = if ($reader.IsDBNull(59)) { "" } else { $reader.GetString(59) }
                $dgtxmkup = if ($reader.IsDBNull(60)) { "" } else { $reader.GetString(60) }
                $dgbin = if ($reader.IsDBNull(61)) { "" } else { $reader.GetString(61) }
                $dgused = if ($reader.IsDBNull(62)) { "" } else { $reader.GetValue(62).ToString() }
                $dguse = if ($reader.IsDBNull(63)) { "" } else { $reader.GetString(63) }
                $dgupc = if ($reader.IsDBNull(64)) { "" } else { $reader.GetString(64) }
                $dgcategory = if ($reader.IsDBNull(65)) { "" } else { $reader.GetString(65) }
                $addDatetime = if ($reader.IsDBNull(66)) { "" } else { $reader.GetValue(66).ToString() }
                
                $rowData = @{
                    DGDESC = $dgdesc
                    DGUM = $dgum
                    DGTYPE = $dgtype
                    DGQ1 = $dgq1
                    DGQ2 = $dgq2
                    DGQ3 = $dgq3
                    DGC1 = $dgc1
                    DGC2 = $dgc2
                    DGC3 = $dgc3
                    DGSHELF = $dgshelf
                    DGINVNO = $dginvno
                    DGGEN1 = $dggen1
                    DGGEN2 = $dggen2
                    DGDATE = $dgdate
                    DGHAS1 = $dghas1
                    DGHAS2 = $dghas2
                    DGHAS3 = $dghas3
                    DGSUPPLIER = $dgsupplier
                    DGLINE1 = $dgline1
                    DGLINE2 = $dgline2
                    DGLINE3 = $dgline3
                    DGORDER1 = $dgorder1
                    DGORDER2 = $dgorder2
                    DGORDER3 = $dgorder3
                    DGMKUP = $dgmkup
                    DGINVNO2 = $dginvno2
                    DGINVNO3 = $dginvno3
                    DGTRADE = $dgtrade
                    DGSIG = $dgsig
                    DGEXPIRE = $dgexpire
                    DG2OLD = $dg2old
                    DGWARN = $dgwarn
                    DGU1 = $dgu1
                    DGU2 = $dgu2
                    DGU3 = $dgu3
                    DGU4 = $dgu4
                    DGU5 = $dgu5
                    DGU6 = $dgu6
                    DGU7 = $dgu7
                    DGU8 = $dgu8
                    DGU9 = $dgu9
                    DGU10 = $dgu10
                    DGU11 = $dgu11
                    DGU12 = $dgu12
                    DGUMON = $dgumon
                    DGPACK = $dgpack
                    DGSIGCODE = $dgsigcode
                    DGCOUNSEL = $dgcounsel
                    DGMSP = $dgmsp
                    DGDAYRATE = $dgdayrate
                    DGWKRATE = $dgwkrate
                    DGMONRATE = $dgmonrate
                    DGPST = $dgpst
                    DGGST = $dggst
                    DGGRACE = $dggrace
                    DGLCADIN = $dglcadin
                    DGLCACOST = $dglcacost
                    DGPACMED = $dgpacmed
                    DGPRICE = $dgprice
                    DGTXMKUP = $dgtxmkup
                    DGBIN = $dgbin
                    DGUSED = $dgused
                    DGUSE = $dguse
                    DGUPC = $dgupc
                    DGCATEGORY = $dgcategory
                    AddDatetime = $addDatetime
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
                elseif ($TableName -eq "Communications") {
                    if ($previousRow.PHN -ne $phn -or 
                        $previousRow.Type -ne $type -or 
                        $previousRow.EventDateTime -ne $eventDateTime -or 
                        $previousRow.Reference -ne $reference -or 
                        $previousRow.Resource -ne $resource) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "DRUG") {
                    if ($previousRow.DGDESC -ne $dgdesc -or 
                        $previousRow.DGUM -ne $dgum -or 
                        $previousRow.DGTYPE -ne $dgtype -or 
                        $previousRow.DGQ1 -ne $dgq1 -or 
                        $previousRow.DGQ2 -ne $dgq2 -or 
                        $previousRow.DGQ3 -ne $dgq3 -or 
                        $previousRow.DGC1 -ne $dgc1 -or 
                        $previousRow.DGC2 -ne $dgc2 -or 
                        $previousRow.DGC3 -ne $dgc3 -or 
                        $previousRow.DGSHELF -ne $dgshelf -or 
                        $previousRow.DGINVNO -ne $dginvno -or 
                        $previousRow.DGGEN1 -ne $dggen1 -or 
                        $previousRow.DGGEN2 -ne $dggen2 -or 
                        $previousRow.DGDATE -ne $dgdate -or 
                        $previousRow.DGHAS1 -ne $dghas1 -or 
                        $previousRow.DGHAS2 -ne $dghas2 -or 
                        $previousRow.DGHAS3 -ne $dghas3 -or 
                        $previousRow.DGSUPPLIER -ne $dgsupplier -or 
                        $previousRow.DGLINE1 -ne $dgline1 -or 
                        $previousRow.DGLINE2 -ne $dgline2 -or 
                        $previousRow.DGLINE3 -ne $dgline3 -or 
                        $previousRow.DGORDER1 -ne $dgorder1 -or 
                        $previousRow.DGORDER2 -ne $dgorder2 -or 
                        $previousRow.DGORDER3 -ne $dgorder3 -or 
                        $previousRow.DGMKUP -ne $dgmkup -or 
                        $previousRow.DGINVNO2 -ne $dginvno2 -or 
                        $previousRow.DGINVNO3 -ne $dginvno3 -or 
                        $previousRow.DGTRADE -ne $dgtrade -or 
                        $previousRow.DGSIG -ne $dgsig -or 
                        $previousRow.DGEXPIRE -ne $dgexpire -or 
                        $previousRow.DG2OLD -ne $dg2old -or 
                        $previousRow.DGWARN -ne $dgwarn -or 
                        $previousRow.DGU1 -ne $dgu1 -or 
                        $previousRow.DGU2 -ne $dgu2 -or 
                        $previousRow.DGU3 -ne $dgu3 -or 
                        $previousRow.DGU4 -ne $dgu4 -or 
                        $previousRow.DGU5 -ne $dgu5 -or 
                        $previousRow.DGU6 -ne $dgu6 -or 
                        $previousRow.DGU7 -ne $dgu7 -or 
                        $previousRow.DGU8 -ne $dgu8 -or 
                        $previousRow.DGU9 -ne $dgu9 -or 
                        $previousRow.DGU10 -ne $dgu10 -or 
                        $previousRow.DGU11 -ne $dgu11 -or 
                        $previousRow.DGU12 -ne $dgu12 -or 
                        $previousRow.DGUMON -ne $dgumon -or 
                        $previousRow.DGPACK -ne $dgpack -or 
                        $previousRow.DGSIGCODE -ne $dgsigcode -or 
                        $previousRow.DGCOUNSEL -ne $dgcounsel -or 
                        $previousRow.DGMSP -ne $dgmsp -or 
                        $previousRow.DGDAYRATE -ne $dgdayrate -or 
                        $previousRow.DGWKRATE -ne $dgwkrate -or 
                        $previousRow.DGMONRATE -ne $dgmonrate -or 
                        $previousRow.DGPST -ne $dgpst -or 
                        $previousRow.DGGST -ne $dggst -or 
                        $previousRow.DGGRACE -ne $dggrace -or 
                        $previousRow.DGLCADIN -ne $dglcadin -or 
                        $previousRow.DGLCACOST -ne $dglcacost -or 
                        $previousRow.DGPACMED -ne $dgpacmed -or 
                        $previousRow.DGPRICE -ne $dgprice -or 
                        $previousRow.DGTXMKUP -ne $dgtxmkup -or 
                        $previousRow.DGBIN -ne $dgbin -or 
                        $previousRow.DGUSED -ne $dgused -or 
                        $previousRow.DGUSE -ne $dguse -or 
                        $previousRow.DGUPC -ne $dgupc -or 
                        $previousRow.DGCATEGORY -ne $dgcategory -or 
                        $previousRow.AddDatetime -ne $addDatetime) {
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
