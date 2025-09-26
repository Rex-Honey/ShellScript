param(
    [int]$CheckInterval = 5,
    [string[]]$IncludeSchemas = @(),
    [string[]]$ExcludeSchemas = @('sys', 'INFORMATION_SCHEMA'),
    [string[]]$ExcludeTables = @()
)

# Database connection
$server = "192.168.29.19,1433\SQLEXPRESS"
$username = "sa"
$password = "dexter"
$database = "medidozeProsper"

# Connection string
$connectionString = "Server=$server;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=true;"

function Convert-ToComparableString {
    param($Value)

    if ($null -eq $Value -or $Value -is [System.DBNull]) {
        return '<NULL>'
    }

    if ($Value -is [byte[]]) {
        return [System.BitConverter]::ToString($Value)
    }

    if ($Value -is [DateTime]) {
        return $Value.ToUniversalTime().ToString('o')
    }

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    try {
        return [System.Convert]::ToString($Value, $culture)
    }
    catch {
        return $Value.ToString()
    }
}

function Get-DatabaseTableMetadata {
    param(
        [string]$ConnectionString,
        [string[]]$IncludeSchemas,
        [string[]]$ExcludeSchemas,
        [string[]]$ExcludeTables
    )

    $metadata = @()
    $connection = $null
    $reader = $null

    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $connection.Open()

        $query = @"
SELECT
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    ISNULL(pk.PrimaryKeyColumns, '') AS PrimaryKeyColumns
FROM INFORMATION_SCHEMA.TABLES AS t
OUTER APPLY (
    SELECT PrimaryKeyColumns = STUFF((
        SELECT ',' + k.COLUMN_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
        INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS k
            ON k.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
           AND k.TABLE_SCHEMA = tc.TABLE_SCHEMA
           AND k.TABLE_NAME = tc.TABLE_NAME
        WHERE tc.TABLE_SCHEMA = t.TABLE_SCHEMA
          AND tc.TABLE_NAME = t.TABLE_NAME
          AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
        ORDER BY k.ORDINAL_POSITION
        FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)'), 1, 1, '')
) pk
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME;
"@

        $command = New-Object System.Data.SqlClient.SqlCommand $query, $connection
        $reader = $command.ExecuteReader()

        while ($reader.Read()) {
            $schema = $reader.GetString(0)
            $table = $reader.GetString(1)
            $pkValue = if ($reader.IsDBNull(2)) { '' } else { $reader.GetString(2) }
            $pkColumns = @()

            if (-not [string]::IsNullOrWhiteSpace($pkValue)) {
                $pkColumns = $pkValue.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            }

            if ($IncludeSchemas -and -not ($IncludeSchemas -contains $schema)) {
                continue
            }

            if ($ExcludeSchemas -and ($ExcludeSchemas -contains $schema)) {
                continue
            }

            if ($ExcludeTables) {
                $fullName = "$schema.$table"
                if ($ExcludeTables -contains $table -or $ExcludeTables -contains $fullName) {
                    continue
                }
            }

            $metadata += @{
                HasPrimaryKey = ($pkColumns.Count -gt 0)
                Schema = $schema
                Name = $table
                FullName = "$schema.$table"
                KeyColumns = $pkColumns
            }
        }
    }
    catch {
        throw "Failed to load metadata: $_"
    }
    finally {
        if ($reader) {
            $reader.Close()
        }
        if ($connection -and $connection.State -eq 'Open') {
            $connection.Close()
        }
    }

    return $metadata
}

function Check-TableChanges {
    param(
        [hashtable]$TableInfo,
        [hashtable]$PreviousData
    )

    $schemaName = $TableInfo.Schema
    $tableName = $TableInfo.Name
    $keyColumns = $TableInfo.KeyColumns

    $connection = $null
    $reader = $null

    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
        $connection.Open()

        $selectQuery = "SELECT * FROM [$schemaName].[$tableName]"
        $orderClause = $null

        if ($keyColumns -and $keyColumns.Count -gt 0) {
            $escapedKeys = $keyColumns | ForEach-Object { "[" + $_ + "]" }
            $orderClause = ' ORDER BY ' + ($escapedKeys -join ', ')
        }

        $commandText = $selectQuery
        if ($orderClause) {
            $commandText += $orderClause
        }
        $command = New-Object System.Data.SqlClient.SqlCommand $commandText, $connection
        $reader = $command.ExecuteReader()

        $currentData = @{}
        $newRows = @()
        $updatedRows = @()

        $effectiveKeyColumns = $null

        while ($reader.Read()) {
            if (-not $effectiveKeyColumns) {
                if ($keyColumns -and $keyColumns.Count -gt 0) {
                    $effectiveKeyColumns = $keyColumns
                }
                elseif ($reader.FieldCount -gt 0) {
                    $effectiveKeyColumns = @($reader.GetName(0))
                }
                else {
                    $effectiveKeyColumns = @()
                }
            }

            $rowColumns = @{}
            $signatureBuilder = New-Object System.Text.StringBuilder

            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $columnName = $reader.GetName($i)
                $value = if ($reader.IsDBNull($i)) { $null } else { $reader.GetValue($i) }
                $comparableValue = Convert-ToComparableString $value

                $rowColumns[$columnName] = $comparableValue
                [void]$signatureBuilder.Append($columnName).Append('=').Append($comparableValue).Append(';')
            }

            $rowSnapshot = @{
                Columns = $rowColumns
                Signature = $signatureBuilder.ToString()
            }

            $keyParts = @()
            foreach ($keyColumn in $effectiveKeyColumns) {
                $columnIndex = $reader.GetOrdinal($keyColumn)
                $keyValue = if ($reader.IsDBNull($columnIndex)) { $null } else { $reader.GetValue($columnIndex) }
                $keyParts += (Convert-ToComparableString $keyValue)
            }

            if ($keyParts.Count -eq 0) {
                $rowIndex = $currentData.Count
                $rowIndexString = $rowIndex.ToString([System.Globalization.CultureInfo]::InvariantCulture)
                $keyParts = @($rowSnapshot.Signature, $rowIndexString)
            }
            $rowKey = [string]::Join('|', $keyParts)
            $currentData[$rowKey] = $rowSnapshot

            if ($PreviousData.ContainsKey($rowKey)) {
                $previousSnapshot = $PreviousData[$rowKey]
                if ($previousSnapshot.Signature -ne $rowSnapshot.Signature) {
                    $changes = @()
                    foreach ($columnName in $rowSnapshot.Columns.Keys) {
                        $currentValue = $rowSnapshot.Columns[$columnName]
                        $previousValue = if ($previousSnapshot.Columns.ContainsKey($columnName)) { $previousSnapshot.Columns[$columnName] } else { '<NULL>' }
                        if ($currentValue -ne $previousValue) {
                            $changes += "${columnName}: '$previousValue' -> '$currentValue'"
                        }
                    }

                    $updatedRows += @{
                        Key = $rowKey
                        Changes = $changes
                    }
                }
            }
            else {
                $newRows += @{
                    Key = $rowKey
                    Data = $rowColumns
                }
            }
        }

        $deletedRows = @()
        foreach ($existingKey in $PreviousData.Keys) {
            if (-not $currentData.ContainsKey($existingKey)) {
                $deletedRows += @{
                    Key = $existingKey
                    Data = $PreviousData[$existingKey].Columns
                }
            }
        }

        return @{
            Success = $true
            NewRows = $newRows
            UpdatedRows = $updatedRows
            DeletedRows = $deletedRows
            CurrentData = $currentData
        }
    }
    catch {
        Write-Error "Database error for table [$schemaName].[$tableName]: $_"
        return @{
            Success = $false
            NewRows = @()
            UpdatedRows = @()
            DeletedRows = @()
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

function Check-AllTables {
    param(
        [array]$TablesMetadata,
        [hashtable]$AllPreviousData
    )

    $allResults = @{}

    foreach ($tableInfo in $TablesMetadata) {
        $tableKey = $tableInfo.FullName
        $previousData = if ($AllPreviousData.ContainsKey($tableKey)) { $AllPreviousData[$tableKey] } else { @{} }
        $result = Check-TableChanges -TableInfo $tableInfo -PreviousData $previousData
        $allResults[$tableKey] = $result
    }

    return $allResults
}

try {
    $tablesMetadata = Get-DatabaseTableMetadata -ConnectionString $connectionString -IncludeSchemas $IncludeSchemas -ExcludeSchemas $ExcludeSchemas -ExcludeTables $ExcludeTables

    if (-not $tablesMetadata) {
        $tablesMetadata = @()
    }

    $tablesWithPrimaryKey = @()
    $tablesWithoutPrimaryKey = @()

    foreach ($tableInfo in $tablesMetadata) {
        if ($tableInfo.HasPrimaryKey) {
            $tablesWithPrimaryKey += $tableInfo
        }
        else {
            $tablesWithoutPrimaryKey += $tableInfo
        }
    }

    if ($tablesWithoutPrimaryKey.Count -gt 0) {
        Write-Warning "Skipping tables without primary keys:"
        foreach ($tableInfo in $tablesWithoutPrimaryKey) {
            Write-Warning "  [$($tableInfo.FullName)] -> primary key not found; skipping"
        }
    }

    $tablesMetadata = $tablesWithPrimaryKey

    if (-not $tablesMetadata -or $tablesMetadata.Count -eq 0) {
        Write-Warning "No tables with primary keys found to monitor. Adjust include/exclude filters or add primary keys."
        return
    }


    Write-Host "Monitoring all tables in database [$database]:"
    foreach ($tableInfo in $tablesMetadata) {
        $keyDescription = if ($tableInfo.KeyColumns.Count -gt 0) { ($tableInfo.KeyColumns -join ', ') } else { 'no primary key detected' }
        Write-Host "  [$($tableInfo.FullName)] -> key columns: $keyDescription"
    }
    Write-Host "Check interval: $CheckInterval seconds"
    Write-Host "Press Ctrl+C to stop"
    Write-Host ""

    $allPreviousData = @{}
    foreach ($tableInfo in $tablesMetadata) {
        $allPreviousData[$tableInfo.FullName] = @{}
    }

    while ($true) {
        try {
            $allResults = Check-AllTables -TablesMetadata $tablesMetadata -AllPreviousData $allPreviousData
            $hasAnyChanges = $false

            foreach ($tableInfo in $tablesMetadata) {
                $tableKey = $tableInfo.FullName
                $result = $allResults[$tableKey]

                if ($result -and $result.Success) {
                    if ($result.NewRows.Count -gt 0) {
                        foreach ($row in $result.NewRows) {
                            Write-Host "table: $tableKey, operation: NEW, key: $($row.Key)" -ForegroundColor Green
                        }
                        $hasAnyChanges = $true
                    }

                    if ($result.UpdatedRows.Count -gt 0) {
                        foreach ($row in $result.UpdatedRows) {
                            $changeSummary = if ($row.Changes -and $row.Changes.Count -gt 0) { [string]::Join(', ', $row.Changes) } else { 'data modified' }
                            Write-Host "table: $tableKey, operation: UPDATED, key: $($row.Key), changes: $changeSummary" -ForegroundColor Yellow
                        }
                        $hasAnyChanges = $true
                    }

                    if ($result.DeletedRows.Count -gt 0) {
                        foreach ($row in $result.DeletedRows) {
                            Write-Host "table: $tableKey, operation: DELETED, key: $($row.Key)" -ForegroundColor Red
                        }
                        $hasAnyChanges = $true
                    }

                    if ($result.CurrentData) {
                        $allPreviousData[$tableKey] = $result.CurrentData
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

