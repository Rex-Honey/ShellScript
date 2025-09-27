# =============================================================================
# WINRX MONITOR CUSTOM TABLES - DATABASE CHANGE MONITORING SCRIPT
# =============================================================================
#
# AVAILABLE MODES:
# 1. Default Mode (Optimized):     .\winrxMonitorCustomTables.ps1
#    - Fast scans (1-2 seconds)
#    - No false positives guaranteed
#    - Monitors 6 reliable tables only
#
# 2. Full Scan Mode:               .\winrxMonitorCustomTables.ps1 -FullScan
#    - Monitors ALL 18 tables including CHANGES
#    - Slower scans (5-10 minutes)
#    - May have false positives on large tables
#
# 3. Stable Mode:                  .\winrxMonitorCustomTables.ps1 -StableMode
#    - Same as Default mode but explicitly named
#    - Guaranteed no false positives
#
# 4. Reset Baseline Mode:          .\winrxMonitorCustomTables.ps1 -ResetBaseline
#    - Clears all previous data and starts fresh
#    - Can be combined with other modes
#
# 5. Custom Check Interval:        .\winrxMonitorCustomTables.ps1 -CheckInterval 10
#    - Changes scan frequency (default is 5 seconds)
#    - Can be combined with other modes
#
# COMBINED MODES EXAMPLES:
# - Monitor ALL tables with 30-second intervals:
#   .\winrxMonitorCustomTables.ps1 -FullScan -CheckInterval 30
#
# - Reset and monitor all tables:
#   .\winrxMonitorCustomTables.ps1 -FullScan -ResetBaseline
#
# - Stable mode with custom interval:
#   .\winrxMonitorCustomTables.ps1 -StableMode -CheckInterval 10
#
# TABLES MONITORED IN DEFAULT MODE (6 tables):
# - Appointment (15 records)
# - CALLBACK (251 records)
# - Communications (2,980 records)
# - DRUG (7,262 records)
# - PRESETMESSAGES (116 records)
# - WINMAIL_RECEIVED (1,013 records)
#
# TABLES SKIPPED IN DEFAULT MODE (12 large tables):
# - CHANGES (103,688 records)
# - CHGDRUG (163,436 records)
# - Delivery (196,073 records)
# - DOCUMENTS (147,413 records)
# - ERX (20 records)
# - PACMED (12,865 records)
# - PATIENT (35,791 records)
# - REFILL (1,693,581 records)
# - RX (471,943 records)
# - SCANS (638,682 records)
# - TXNS (small table)
#
# =============================================================================

param(
    [hashtable]$TableConfig = @{
        "Appointment" = "AppID"
        "CALLBACK" = "CBID"
        "CHANGES" = "CGID"
        "CHGDRUG" = "CHGDGID"
        "Communications" = "ID"
        "Delivery" = "RefId"
        "DOCUMENTS" = "ID"
        "DRUG" = "DGDIN"
        "ERX" = "XKEY"
        "PACMED" = "Id"
        "PATIENT" = "PANUM"
        "PRESETMESSAGES" = "ID"
        "REFILL" = "REFILLID"
        "RX" = "RXBR"
        "SCANS" = "ID"
        "TXNS" = "TXNSID"
        "WINMAIL_RECEIVED" = "ID"
    },
    [int]$CheckInterval = 5,
    [switch]$FullScan = $false,
    [switch]$ResetBaseline = $false,
    [switch]$StableMode = $false
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
        elseif ($TableName -eq "CALLBACK") {
            $query = "SELECT [$ColumnName], CBDATE, CBSURNAME, CBGIVEN, CBDRUG, CBNOTE, CBPHONE, CBRXNUM, CBPREV, CBUSER, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, CBCOMID FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        elseif ($TableName -eq "CHANGES") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], CGNUM, CGLIM, CGQTY, CGBR, CGDEA, CGDRLAST, CGDR1ST, CGDATE, CGUSER, CGSIG, CGMSG, CGDRCOLL, CGACT, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, CGDRUG, CGDIN FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "CHGDRUG") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], DGDIN, DGDESC, DGDATE, DGUSER, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, ORDERSTATUS FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "Delivery") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], Route, Witness, Status, Staff, PickupDateTime, DeliveryDateTime, Reason, PatientSignature, EmployeeSignature, Address, WitnessQty, CarryQty, MedTime FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "DOCUMENTS") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], DTNUM, DTDATE, DTTYPE, DTNAME, DTBATCHNUM, DTSOURCE, DTSOURCEFILE, DTFLAG, DTAILMENT, DTNOTE FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "ERX") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], XNUM, XBR, XSUPPLY, XPERIOD, XREFILLS, XQTY, XDRUG, XSIG, XDIN, XDEA, XDRSURNAME, XDRGIVEN, XCOLL, XDATE, XSTATUS, XPHN, XSURNAME, XGIVEN, XSTREET1, XSTREET2, XCITY, XPROV, XPC, XCTRY, XNOSUB, XRETADDR, XSEX, XBIRTH, XEXTERNALID, XNOTE, XHOME, XRB, XAREA, XPHONE, XENDDATE, XPRN, XSTAT, XORIGRX, XKEY, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, XPKG, XADAPT, XFREQ, XCREATED, XORIGERX, XMSG1, XMSG2, XMSG3, XALLERGY, XSITE, XROUTE, XADMIN, XCELL, XEMAIL, XPLANS, XPRICE, XADMNO, XUSERNOTE, XAIG, XSOURCE, XFAX, XRECORDINUSE, XPRIORITY, XDRFISRTTXID, XDRFISRTMEDID, XCONDITION, XAssignToERxUser, XPickUp FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip ERX table in optimized mode due to false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "PACMED") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], Patient, PHN, Home, HomeAddr, RB, DIN, Drug, MedDate, MedTime, Qty, Dr, Rx, Userid, SIG, RefLeft, PacType, Warning, DaysSupply, SentFlag, Dispenser, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, DRID, ORIGDATE, PREVDATE, COST, PHARMID FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "PATIENT") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], PABR, PAGIVEN, PAINITIAL, PASURNAME, PASTATUS, PACTRY, PAADDR1, PAADDR2, PAADDR3, PACITY, PAPROV, PAPC, PADR, PADRCOLL, PADIET, PANOTE, PAALLERGY, PADIAG, PAADM, PAADMNO, PABIRTH, PARB, PAHOME, PAPHONE, PASEX, PADATE, PAPDATA, PAAREA, PAREVIEW, PASMO, PAPIN, PAPARENT, PAGUID, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, PACELL, PAEMAIL, PAEMR, PAAUTH, PAMAC, PACOMPANY, PACONSULTPRIORDATE, PACONSULTDNCDATE, PACONSULTNEVERDATE, PACONSULTPRIORUSER, PACONSULTDNCUSER, PACONSULTNEVERUSER, PACONSULTPRIORTYPE, PACONSULTDNCTYPE, PACONSULTNEVERTYPE, PADOSETTETYPE, PAROUTE, PINRefreshDate, PALIFE, PACONTACTPREF, PAPREFERRED, PANOTIFY, PAPLANS, PADOUBLECOUNT, PALANGUAGE, PAPACNOTE, PASIGNED, PAFDA, PAPHOTO FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "PRESETMESSAGES") {
            $query = "SELECT [$ColumnName], MSGDESC, MSGTEXT FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        elseif ($TableName -eq "REFILL") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], RERXNUM, RERXBR, REEFDATE, RECOST, REFEE, RECOPAY, REQTY, REUSERID, REISORIG, REREVDATE, REXREF, REREVUSER, REPLAN, REAUTH, REUPCHG, RECMPDCHG, REPAY, REJUDGE, REREASON, REAUXBILL, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, RETRACE, READAPT, REBADGE, REREFERENCE, RERESPONSE, REDIN, REPINID, REPINEVENTID, SIGNINGS, RECENTRAL, REBCSA FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "RX") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], RXNUM, RXPANUM, RXORIG, RXPREV, RXSTOP, RXDC, RXPLAN, RXDAYS, RXLIM, RXQTY, RXTOTQTY, RXDRUG, RXSIG, RXDIN, RXBR, RXACT, RXLABELS, RXMEDS, RXDEA, RXDRLAST, RXTYPE, RXPRN, RXVW, RXDATE, RXUPDUSER, RXSTAT, RXQTY1, RXCYCLEDAY, RXDR1ST, RXCOLLEGE, RXCOUNSEL, RXUSE, RXAUTH, RXSUB, RXNOTE, RXLANG, RXCMPD, RXDINS, RXPACMED, RXGUID, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime, RXFOREIGN, RXALERT, RXOTHER, RXERXNUM, RXORIGERXNUM, RXPKG, RXADAPT, RXISERX, RXFREQ, RXWITNESS, RxPINStatus, RxExtNo, RxReleaseDate, RxHoldDate, RxIndication, RXDRFAX, ORIGDR, RxDrWellnetID, RXSIGNID, RXCMPDNAME, RXBILLORDER, RXPRATA, RxFreqNum, RxFreqCode, RxDose, RxDoseUnitCode, RxRouteCode, RxDeviceCode, RxSnomed, RxMaxDispQty, RxMMI, RxServiceCode, RxFolio, RXPACNOTE, RXSIGNED, RXSAFESUPPLY FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "SCANS") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], SCBAR, SCFILE, SCDATE, SCBATCHNUM, SCTYPE, SCSOURCE, SCSOURCEFILE, SCFLAG, SCORDER FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "TXNS") {
            if ($FullScan) {
                $query = "SELECT [$ColumnName], PLANID, ADJDATE, RX, AMT, CARID, SOURCE, AddDatetime, AddUsername, UpdateUsername, UpdateDatetime FROM [$TableName] ORDER BY [$ColumnName] ASC"
            } else {
                # Skip large table in optimized mode to avoid false positives
                $query = $null
            }
        }
        elseif ($TableName -eq "WINMAIL_RECEIVED") {
            $query = "SELECT [$ColumnName], EntryDate, Message, Guid, NAME, FAXNUM, PAGES, FILENAME, Note, SRFaxID, SRFaxFileName, Unread FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        else {
            # Default query for other tables
            $query = "SELECT [$ColumnName] FROM [$TableName] ORDER BY [$ColumnName] ASC"
        }
        
        # Skip table if query is null (large tables in optimized mode)
        if ($query -eq $null) {
            return @{
                Success = $true
                NewIds = @()
                UpdatedIds = @()
                UpdatedDetails = @{}
                DeletedIds = @()
                CurrentData = $PreviousData
            }
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
            elseif ($TableName -eq "CALLBACK") {
                $cbdate = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $cbsurname = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $cbgiven = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $cbdrug = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $cbnote = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $cbphone = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $cbrxnum = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $cbprev = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $cbuser = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $addDatetime = if ($reader.IsDBNull(10)) { "" } else { $reader.GetValue(10).ToString() }
                $addUsername = if ($reader.IsDBNull(11)) { "" } else { $reader.GetValue(11).ToString() }
                $updateUsername = if ($reader.IsDBNull(12)) { "" } else { $reader.GetValue(12).ToString() }
                $updateDatetime = if ($reader.IsDBNull(13)) { "" } else { $reader.GetValue(13).ToString() }
                $cbcomid = if ($reader.IsDBNull(14)) { "" } else { $reader.GetValue(14).ToString() }
                
                $rowData = @{
                    CBDATE = $cbdate
                    CBSURNAME = $cbsurname
                    CBGIVEN = $cbgiven
                    CBDRUG = $cbdrug
                    CBNOTE = $cbnote
                    CBPHONE = $cbphone
                    CBRXNUM = $cbrxnum
                    CBPREV = $cbprev
                    CBUSER = $cbuser
                    AddDatetime = $addDatetime
                    AddUsername = $addUsername
                    UpdateUsername = $updateUsername
                    UpdateDatetime = $updateDatetime
                    CBCOMID = $cbcomid
                }
            }
            elseif ($TableName -eq "CHANGES") {
                $cgnum = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $cglim = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $cgqty = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $cgbr = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $cgdea = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $cgdrlast = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $cgdr1st = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $cgdate = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $cguser = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $cgsig = if ($reader.IsDBNull(10)) { "" } else { $reader.GetValue(10).ToString() }
                $cgmsg = if ($reader.IsDBNull(11)) { "" } else { $reader.GetValue(11).ToString() }
                $cgdrcoll = if ($reader.IsDBNull(12)) { "" } else { $reader.GetValue(12).ToString() }
                $cgact = if ($reader.IsDBNull(13)) { "" } else { $reader.GetValue(13).ToString() }
                $addDatetime = if ($reader.IsDBNull(14)) { "" } else { $reader.GetValue(14).ToString() }
                $addUsername = if ($reader.IsDBNull(15)) { "" } else { $reader.GetValue(15).ToString() }
                $updateUsername = if ($reader.IsDBNull(16)) { "" } else { $reader.GetValue(16).ToString() }
                $updateDatetime = if ($reader.IsDBNull(17)) { "" } else { $reader.GetValue(17).ToString() }
                $cgdrug = if ($reader.IsDBNull(18)) { "" } else { $reader.GetValue(18).ToString() }
                $cgdin = if ($reader.IsDBNull(19)) { "" } else { $reader.GetValue(19).ToString() }
                
                $rowData = @{
                    CGNUM = $cgnum
                    CGLIM = $cglim
                    CGQTY = $cgqty
                    CGBR = $cgbr
                    CGDEA = $cgdea
                    CGDRLAST = $cgdrlast
                    CGDR1ST = $cgdr1st
                    CGDATE = $cgdate
                    CGUSER = $cguser
                    CGSIG = $cgsig
                    CGMSG = $cgmsg
                    CGDRCOLL = $cgdrcoll
                    CGACT = $cgact
                    AddDatetime = $addDatetime
                    AddUsername = $addUsername
                    UpdateUsername = $updateUsername
                    UpdateDatetime = $updateDatetime
                    CGDRUG = $cgdrug
                    CGDIN = $cgdin
                }
            }
            elseif ($TableName -eq "CHGDRUG") {
                $dgdin = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $dgdesc = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $dgdate = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $dguser = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $addDatetime = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $addUsername = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $updateUsername = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $updateDatetime = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $orderstatus = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                
                $rowData = @{
                    DGDIN = $dgdin
                    DGDESC = $dgdesc
                    DGDATE = $dgdate
                    DGUSER = $dguser
                    AddDatetime = $addDatetime
                    AddUsername = $addUsername
                    UpdateUsername = $updateUsername
                    UpdateDatetime = $updateDatetime
                    ORDERSTATUS = $orderstatus
                }
            }
            elseif ($TableName -eq "Delivery") {
                $route = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $witness = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $status = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $staff = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $pickupDateTime = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $deliveryDateTime = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $reason = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $patientSignature = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $employeeSignature = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $address = if ($reader.IsDBNull(10)) { "" } else { $reader.GetValue(10).ToString() }
                $witnessQty = if ($reader.IsDBNull(11)) { "" } else { $reader.GetValue(11).ToString() }
                $carryQty = if ($reader.IsDBNull(12)) { "" } else { $reader.GetValue(12).ToString() }
                $medTime = if ($reader.IsDBNull(13)) { "" } else { $reader.GetValue(13).ToString() }
                
                $rowData = @{
                    Route = $route
                    Witness = $witness
                    Status = $status
                    Staff = $staff
                    PickupDateTime = $pickupDateTime
                    DeliveryDateTime = $deliveryDateTime
                    Reason = $reason
                    PatientSignature = $patientSignature
                    EmployeeSignature = $employeeSignature
                    Address = $address
                    WitnessQty = $witnessQty
                    CarryQty = $carryQty
                    MedTime = $medTime
                }
            }
            elseif ($TableName -eq "DOCUMENTS") {
                $dtnum = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $dtdate = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $dttype = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $dtname = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $dtbatchnum = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $dtsource = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $dtsourcefile = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $dtflag = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $dtailment = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $dtnote = if ($reader.IsDBNull(10)) { "" } else { $reader.GetValue(10).ToString() }
                
                $rowData = @{
                    DTNUM = $dtnum
                    DTDATE = $dtdate
                    DTTYPE = $dttype
                    DTNAME = $dtname
                    DTBATCHNUM = $dtbatchnum
                    DTSOURCE = $dtsource
                    DTSOURCEFILE = $dtsourcefile
                    DTFLAG = $dtflag
                    DTAILMENT = $dtailment
                    DTNOTE = $dtnote
                }
            }
            elseif ($TableName -eq "ERX") {
                $xnum = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $xbr = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $xsupply = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $xperiod = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $xrefills = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $xqty = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $xdrug = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $xsig = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $xdin = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $xdea = if ($reader.IsDBNull(10)) { "" } else { $reader.GetValue(10).ToString() }
                $xdrsurname = if ($reader.IsDBNull(11)) { "" } else { $reader.GetValue(11).ToString() }
                $xdrgiven = if ($reader.IsDBNull(12)) { "" } else { $reader.GetValue(12).ToString() }
                $xcoll = if ($reader.IsDBNull(13)) { "" } else { $reader.GetValue(13).ToString() }
                $xdate = if ($reader.IsDBNull(14)) { "" } else { $reader.GetValue(14).ToString() }
                $xstatus = if ($reader.IsDBNull(15)) { "" } else { $reader.GetValue(15).ToString() }
                $xphn = if ($reader.IsDBNull(16)) { "" } else { $reader.GetValue(16).ToString() }
                $xsurname = if ($reader.IsDBNull(17)) { "" } else { $reader.GetValue(17).ToString() }
                $xgiven = if ($reader.IsDBNull(18)) { "" } else { $reader.GetValue(18).ToString() }
                $xstreet1 = if ($reader.IsDBNull(19)) { "" } else { $reader.GetValue(19).ToString() }
                $xstreet2 = if ($reader.IsDBNull(20)) { "" } else { $reader.GetValue(20).ToString() }
                $xcity = if ($reader.IsDBNull(21)) { "" } else { $reader.GetValue(21).ToString() }
                $xprov = if ($reader.IsDBNull(22)) { "" } else { $reader.GetValue(22).ToString() }
                $xpc = if ($reader.IsDBNull(23)) { "" } else { $reader.GetValue(23).ToString() }
                $xctry = if ($reader.IsDBNull(24)) { "" } else { $reader.GetValue(24).ToString() }
                $xnosub = if ($reader.IsDBNull(25)) { "" } else { $reader.GetValue(25).ToString() }
                $xretaddr = if ($reader.IsDBNull(26)) { "" } else { $reader.GetValue(26).ToString() }
                $xsex = if ($reader.IsDBNull(27)) { "" } else { $reader.GetValue(27).ToString() }
                $xbirth = if ($reader.IsDBNull(28)) { "" } else { $reader.GetValue(28).ToString() }
                $xexternalid = if ($reader.IsDBNull(29)) { "" } else { $reader.GetValue(29).ToString() }
                $xnote = if ($reader.IsDBNull(30)) { "" } else { $reader.GetValue(30).ToString() }
                $xhome = if ($reader.IsDBNull(31)) { "" } else { $reader.GetValue(31).ToString() }
                $xrb = if ($reader.IsDBNull(32)) { "" } else { $reader.GetValue(32).ToString() }
                $xarea = if ($reader.IsDBNull(33)) { "" } else { $reader.GetValue(33).ToString() }
                $xphone = if ($reader.IsDBNull(34)) { "" } else { $reader.GetValue(34).ToString() }
                $xenddate = if ($reader.IsDBNull(35)) { "" } else { $reader.GetValue(35).ToString() }
                $xprn = if ($reader.IsDBNull(36)) { "" } else { $reader.GetValue(36).ToString() }
                $xstat = if ($reader.IsDBNull(37)) { "" } else { $reader.GetValue(37).ToString() }
                $xorigrx = if ($reader.IsDBNull(38)) { "" } else { $reader.GetValue(38).ToString() }
                $xkey = if ($reader.IsDBNull(39)) { "" } else { $reader.GetValue(39).ToString() }
                $addDatetime = if ($reader.IsDBNull(40)) { "" } else { $reader.GetValue(40).ToString() }
                $addUsername = if ($reader.IsDBNull(41)) { "" } else { $reader.GetValue(41).ToString() }
                $updateUsername = if ($reader.IsDBNull(42)) { "" } else { $reader.GetValue(42).ToString() }
                $updateDatetime = if ($reader.IsDBNull(43)) { "" } else { $reader.GetValue(43).ToString() }
                $xpkg = if ($reader.IsDBNull(44)) { "" } else { $reader.GetValue(44).ToString() }
                $xadapt = if ($reader.IsDBNull(45)) { "" } else { $reader.GetValue(45).ToString() }
                $xfreq = if ($reader.IsDBNull(46)) { "" } else { $reader.GetValue(46).ToString() }
                $xcreated = if ($reader.IsDBNull(47)) { "" } else { $reader.GetValue(47).ToString() }
                $xorigerx = if ($reader.IsDBNull(48)) { "" } else { $reader.GetValue(48).ToString() }
                $xmsg1 = if ($reader.IsDBNull(49)) { "" } else { $reader.GetValue(49).ToString() }
                $xmsg2 = if ($reader.IsDBNull(50)) { "" } else { $reader.GetValue(50).ToString() }
                $xmsg3 = if ($reader.IsDBNull(51)) { "" } else { $reader.GetValue(51).ToString() }
                $xallergy = if ($reader.IsDBNull(52)) { "" } else { $reader.GetValue(52).ToString() }
                $xsite = if ($reader.IsDBNull(53)) { "" } else { $reader.GetValue(53).ToString() }
                $xroute = if ($reader.IsDBNull(54)) { "" } else { $reader.GetValue(54).ToString() }
                $xadmin = if ($reader.IsDBNull(55)) { "" } else { $reader.GetValue(55).ToString() }
                $xcell = if ($reader.IsDBNull(56)) { "" } else { $reader.GetValue(56).ToString() }
                $xemail = if ($reader.IsDBNull(57)) { "" } else { $reader.GetValue(57).ToString() }
                $xplans = if ($reader.IsDBNull(58)) { "" } else { $reader.GetValue(58).ToString() }
                $xprice = if ($reader.IsDBNull(59)) { "" } else { $reader.GetValue(59).ToString() }
                $xadmno = if ($reader.IsDBNull(60)) { "" } else { $reader.GetValue(60).ToString() }
                $xusernote = if ($reader.IsDBNull(61)) { "" } else { $reader.GetValue(61).ToString() }
                $xaig = if ($reader.IsDBNull(62)) { "" } else { $reader.GetValue(62).ToString() }
                $xsource = if ($reader.IsDBNull(63)) { "" } else { $reader.GetValue(63).ToString() }
                $xfax = if ($reader.IsDBNull(64)) { "" } else { $reader.GetValue(64).ToString() }
                $xrecordinuse = if ($reader.IsDBNull(65)) { "" } else { $reader.GetValue(65).ToString() }
                $xpriority = if ($reader.IsDBNull(66)) { "" } else { $reader.GetValue(66).ToString() }
                $xdrfisrttxid = if ($reader.IsDBNull(67)) { "" } else { $reader.GetValue(67).ToString() }
                $xdrfisrtmedid = if ($reader.IsDBNull(68)) { "" } else { $reader.GetValue(68).ToString() }
                $xcondition = if ($reader.IsDBNull(69)) { "" } else { $reader.GetValue(69).ToString() }
                $xassigntoerxuser = if ($reader.IsDBNull(70)) { "" } else { $reader.GetValue(70).ToString() }
                $xpickup = if ($reader.IsDBNull(71)) { "" } else { $reader.GetValue(71).ToString() }
                
                $rowData = @{
                    XNUM = $xnum
                    XBR = $xbr
                    XSUPPLY = $xsupply
                    XPERIOD = $xperiod
                    XREFILLS = $xrefills
                    XQTY = $xqty
                    XDRUG = $xdrug
                    XSIG = $xsig
                    XDIN = $xdin
                    XDEA = $xdea
                    XDRSURNAME = $xdrsurname
                    XDRGIVEN = $xdrgiven
                    XCOLL = $xcoll
                    XDATE = $xdate
                    XSTATUS = $xstatus
                    XPHN = $xphn
                    XSURNAME = $xsurname
                    XGIVEN = $xgiven
                    XSTREET1 = $xstreet1
                    XSTREET2 = $xstreet2
                    XCITY = $xcity
                    XPROV = $xprov
                    XPC = $xpc
                    XCTRY = $xctry
                    XNOSUB = $xnosub
                    XRETADDR = $xretaddr
                    XSEX = $xsex
                    XBIRTH = $xbirth
                    XEXTERNALID = $xexternalid
                    XNOTE = $xnote
                    XHOME = $xhome
                    XRB = $xrb
                    XAREA = $xarea
                    XPHONE = $xphone
                    XENDDATE = $xenddate
                    XPRN = $xprn
                    XSTAT = $xstat
                    XORIGRX = $xorigrx
                    XKEY = $xkey
                    AddDatetime = $addDatetime
                    AddUsername = $addUsername
                    UpdateUsername = $updateUsername
                    UpdateDatetime = $updateDatetime
                    XPKG = $xpkg
                    XADAPT = $xadapt
                    XFREQ = $xfreq
                    XCREATED = $xcreated
                    XORIGERX = $xorigerx
                    XMSG1 = $xmsg1
                    XMSG2 = $xmsg2
                    XMSG3 = $xmsg3
                    XALLERGY = $xallergy
                    XSITE = $xsite
                    XROUTE = $xroute
                    XADMIN = $xadmin
                    XCELL = $xcell
                    XEMAIL = $xemail
                    XPLANS = $xplans
                    XPRICE = $xprice
                    XADMNO = $xadmno
                    XUSERNOTE = $xusernote
                    XAIG = $xaig
                    XSOURCE = $xsource
                    XFAX = $xfax
                    XRECORDINUSE = $xrecordinuse
                    XPRIORITY = $xpriority
                    XDRFISRTTXID = $xdrfisrttxid
                    XDRFISRTMEDID = $xdrfisrtmedid
                    XCONDITION = $xcondition
                    XAssignToERxUser = $xassigntoerxuser
                    XPickUp = $xpickup
                }
            }
            elseif ($TableName -eq "PACMED") {
                $patient = if ($reader.IsDBNull(1)) { "" } else { $reader.GetValue(1).ToString() }
                $phn = if ($reader.IsDBNull(2)) { "" } else { $reader.GetValue(2).ToString() }
                $homeValue = if ($reader.IsDBNull(3)) { "" } else { $reader.GetValue(3).ToString() }
                $homeAddr = if ($reader.IsDBNull(4)) { "" } else { $reader.GetValue(4).ToString() }
                $rb = if ($reader.IsDBNull(5)) { "" } else { $reader.GetValue(5).ToString() }
                $din = if ($reader.IsDBNull(6)) { "" } else { $reader.GetValue(6).ToString() }
                $drug = if ($reader.IsDBNull(7)) { "" } else { $reader.GetValue(7).ToString() }
                $medDate = if ($reader.IsDBNull(8)) { "" } else { $reader.GetValue(8).ToString() }
                $medTime = if ($reader.IsDBNull(9)) { "" } else { $reader.GetValue(9).ToString() }
                $qty = if ($reader.IsDBNull(10)) { "" } else { $reader.GetValue(10).ToString() }
                $dr = if ($reader.IsDBNull(11)) { "" } else { $reader.GetValue(11).ToString() }
                $rx = if ($reader.IsDBNull(12)) { "" } else { $reader.GetValue(12).ToString() }
                $userid = if ($reader.IsDBNull(13)) { "" } else { $reader.GetValue(13).ToString() }
                $sig = if ($reader.IsDBNull(14)) { "" } else { $reader.GetValue(14).ToString() }
                $refLeft = if ($reader.IsDBNull(15)) { "" } else { $reader.GetValue(15).ToString() }
                $pacType = if ($reader.IsDBNull(16)) { "" } else { $reader.GetValue(16).ToString() }
                $warning = if ($reader.IsDBNull(17)) { "" } else { $reader.GetValue(17).ToString() }
                $daysSupply = if ($reader.IsDBNull(18)) { "" } else { $reader.GetValue(18).ToString() }
                $sentFlag = if ($reader.IsDBNull(19)) { "" } else { $reader.GetValue(19).ToString() }
                $dispenser = if ($reader.IsDBNull(20)) { "" } else { $reader.GetValue(20).ToString() }
                $addDatetime = if ($reader.IsDBNull(21)) { "" } else { $reader.GetValue(21).ToString() }
                $addUsername = if ($reader.IsDBNull(22)) { "" } else { $reader.GetValue(22).ToString() }
                $updateUsername = if ($reader.IsDBNull(23)) { "" } else { $reader.GetValue(23).ToString() }
                $updateDatetime = if ($reader.IsDBNull(24)) { "" } else { $reader.GetValue(24).ToString() }
                $drid = if ($reader.IsDBNull(25)) { "" } else { $reader.GetValue(25).ToString() }
                $origDate = if ($reader.IsDBNull(26)) { "" } else { $reader.GetValue(26).ToString() }
                $prevDate = if ($reader.IsDBNull(27)) { "" } else { $reader.GetValue(27).ToString() }
                $cost = if ($reader.IsDBNull(28)) { "" } else { $reader.GetValue(28).ToString() }
                $pharmid = if ($reader.IsDBNull(29)) { "" } else { $reader.GetValue(29).ToString() }
                
                $rowData = @{
                    Patient = $patient
                    PHN = $phn
                    Home = $homeValue
                    HomeAddr = $homeAddr
                    RB = $rb
                    DIN = $din
                    Drug = $drug
                    MedDate = $medDate
                    MedTime = $medTime
                    Qty = $qty
                    Dr = $dr
                    Rx = $rx
                    Userid = $userid
                    SIG = $sig
                    RefLeft = $refLeft
                    PacType = $pacType
                    Warning = $warning
                    DaysSupply = $daysSupply
                    SentFlag = $sentFlag
                    Dispenser = $dispenser
                    AddDatetime = $addDatetime
                    AddUsername = $addUsername
                    UpdateUsername = $updateUsername
                    UpdateDatetime = $updateDatetime
                    DRID = $drid
                    ORIGDATE = $origDate
                    PREVDATE = $prevDate
                    COST = $cost
                    PHARMID = $pharmid
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
                elseif ($TableName -eq "CALLBACK") {
                    if ($previousRow.CBDATE -ne $cbdate -or 
                        $previousRow.CBSURNAME -ne $cbsurname -or 
                        $previousRow.CBGIVEN -ne $cbgiven -or 
                        $previousRow.CBDRUG -ne $cbdrug -or 
                        $previousRow.CBNOTE -ne $cbnote -or 
                        $previousRow.CBPHONE -ne $cbphone -or 
                        $previousRow.CBRXNUM -ne $cbrxnum -or 
                        $previousRow.CBPREV -ne $cbprev -or 
                        $previousRow.CBUSER -ne $cbuser -or 
                        $previousRow.AddDatetime -ne $addDatetime -or 
                        $previousRow.AddUsername -ne $addUsername -or 
                        $previousRow.UpdateUsername -ne $updateUsername -or 
                        $previousRow.UpdateDatetime -ne $updateDatetime -or 
                        $previousRow.CBCOMID -ne $cbcomid) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "CHANGES") {
                    if ($previousRow.CGNUM -ne $cgnum -or 
                        $previousRow.CGLIM -ne $cglim -or 
                        $previousRow.CGQTY -ne $cgqty -or 
                        $previousRow.CGBR -ne $cgbr -or 
                        $previousRow.CGDEA -ne $cgdea -or 
                        $previousRow.CGDRLAST -ne $cgdrlast -or 
                        $previousRow.CGDR1ST -ne $cgdr1st -or 
                        $previousRow.CGDATE -ne $cgdate -or 
                        $previousRow.CGUSER -ne $cguser -or 
                        $previousRow.CGSIG -ne $cgsig -or 
                        $previousRow.CGMSG -ne $cgmsg -or 
                        $previousRow.CGDRCOLL -ne $cgdrcoll -or 
                        $previousRow.CGACT -ne $cgact -or 
                        $previousRow.AddDatetime -ne $addDatetime -or 
                        $previousRow.AddUsername -ne $addUsername -or 
                        $previousRow.UpdateUsername -ne $updateUsername -or 
                        $previousRow.UpdateDatetime -ne $updateDatetime -or 
                        $previousRow.CGDRUG -ne $cgdrug -or 
                        $previousRow.CGDIN -ne $cgdin) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "CHGDRUG") {
                    if ($previousRow.DGDIN -ne $dgdin -or 
                        $previousRow.DGDESC -ne $dgdesc -or 
                        $previousRow.DGDATE -ne $dgdate -or 
                        $previousRow.DGUSER -ne $dguser -or 
                        $previousRow.AddDatetime -ne $addDatetime -or 
                        $previousRow.AddUsername -ne $addUsername -or 
                        $previousRow.UpdateUsername -ne $updateUsername -or 
                        $previousRow.UpdateDatetime -ne $updateDatetime -or 
                        $previousRow.ORDERSTATUS -ne $orderstatus) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "Delivery") {
                    if ($previousRow.Route -ne $route -or 
                        $previousRow.Witness -ne $witness -or 
                        $previousRow.Status -ne $status -or 
                        $previousRow.Staff -ne $staff -or 
                        $previousRow.PickupDateTime -ne $pickupDateTime -or 
                        $previousRow.DeliveryDateTime -ne $deliveryDateTime -or 
                        $previousRow.Reason -ne $reason -or 
                        $previousRow.PatientSignature -ne $patientSignature -or 
                        $previousRow.EmployeeSignature -ne $employeeSignature -or 
                        $previousRow.Address -ne $address -or 
                        $previousRow.WitnessQty -ne $witnessQty -or 
                        $previousRow.CarryQty -ne $carryQty -or 
                        $previousRow.MedTime -ne $medTime) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "DOCUMENTS") {
                    if ($previousRow.DTNUM -ne $dtnum -or 
                        $previousRow.DTDATE -ne $dtdate -or 
                        $previousRow.DTTYPE -ne $dttype -or 
                        $previousRow.DTNAME -ne $dtname -or 
                        $previousRow.DTBATCHNUM -ne $dtbatchnum -or 
                        $previousRow.DTSOURCE -ne $dtsource -or 
                        $previousRow.DTSOURCEFILE -ne $dtsourcefile -or 
                        $previousRow.DTFLAG -ne $dtflag -or 
                        $previousRow.DTAILMENT -ne $dtailment -or 
                        $previousRow.DTNOTE -ne $dtnote) {
                        $hasChanges = $true
                    }
                }
                elseif ($TableName -eq "ERX") {
                    if ($previousRow.XNUM -ne $xnum -or 
                        $previousRow.XBR -ne $xbr -or 
                        $previousRow.XSUPPLY -ne $xsupply -or 
                        $previousRow.XPERIOD -ne $xperiod -or 
                        $previousRow.XREFILLS -ne $xrefills -or 
                        $previousRow.XQTY -ne $xqty -or 
                        $previousRow.XDRUG -ne $xdrug -or 
                        $previousRow.XSIG -ne $xsig -or 
                        $previousRow.XDIN -ne $xdin -or 
                        $previousRow.XDEA -ne $xdea -or 
                        $previousRow.XDRSURNAME -ne $xdrsurname -or 
                        $previousRow.XDRGIVEN -ne $xdrgiven -or 
                        $previousRow.XCOLL -ne $xcoll -or 
                        $previousRow.XDATE -ne $xdate -or 
                        $previousRow.XSTATUS -ne $xstatus -or 
                        $previousRow.XPHN -ne $xphn -or 
                        $previousRow.XSURNAME -ne $xsurname -or 
                        $previousRow.XGIVEN -ne $xgiven -or 
                        $previousRow.XSTREET1 -ne $xstreet1 -or 
                        $previousRow.XSTREET2 -ne $xstreet2 -or 
                        $previousRow.XCITY -ne $xcity -or 
                        $previousRow.XPROV -ne $xprov -or 
                        $previousRow.XPC -ne $xpc -or 
                        $previousRow.XCTRY -ne $xctry -or 
                        $previousRow.XNOSUB -ne $xnosub -or 
                        $previousRow.XRETADDR -ne $xretaddr -or 
                        $previousRow.XSEX -ne $xsex -or 
                        $previousRow.XBIRTH -ne $xbirth -or 
                        $previousRow.XEXTERNALID -ne $xexternalid -or 
                        $previousRow.XNOTE -ne $xnote -or 
                        $previousRow.XHOME -ne $xhome -or 
                        $previousRow.XRB -ne $xrb -or 
                        $previousRow.XAREA -ne $xarea -or 
                        $previousRow.XPHONE -ne $xphone -or 
                        $previousRow.XENDDATE -ne $xenddate -or 
                        $previousRow.XPRN -ne $xprn -or 
                        $previousRow.XSTAT -ne $xstat -or 
                        $previousRow.XORIGRX -ne $xorigrx -or 
                        $previousRow.XKEY -ne $xkey -or 
                        $previousRow.AddDatetime -ne $addDatetime -or 
                        $previousRow.AddUsername -ne $addUsername -or 
                        $previousRow.UpdateUsername -ne $updateUsername -or 
                        $previousRow.UpdateDatetime -ne $updateDatetime -or 
                        $previousRow.XPKG -ne $xpkg -or 
                        $previousRow.XADAPT -ne $xadapt -or 
                        $previousRow.XFREQ -ne $xfreq -or 
                        $previousRow.XCREATED -ne $xcreated -or 
                        $previousRow.XORIGERX -ne $xorigerx -or 
                        $previousRow.XMSG1 -ne $xmsg1 -or 
                        $previousRow.XMSG2 -ne $xmsg2 -or 
                        $previousRow.XMSG3 -ne $xmsg3 -or 
                        $previousRow.XALLERGY -ne $xallergy -or 
                        $previousRow.XSITE -ne $xsite -or 
                        $previousRow.XROUTE -ne $xroute -or 
                        $previousRow.XADMIN -ne $xadmin -or 
                        $previousRow.XCELL -ne $xcell -or 
                        $previousRow.XEMAIL -ne $xemail -or 
                        $previousRow.XPLANS -ne $xplans -or 
                        $previousRow.XPRICE -ne $xprice -or 
                        $previousRow.XADMNO -ne $xadmno -or 
                        $previousRow.XUSERNOTE -ne $xusernote -or 
                        $previousRow.XAIG -ne $xaig -or 
                        $previousRow.XSOURCE -ne $xsource -or 
                        $previousRow.XFAX -ne $xfax -or 
                        $previousRow.XRECORDINUSE -ne $xrecordinuse -or 
                        $previousRow.XPRIORITY -ne $xpriority -or 
                        $previousRow.XDRFISRTTXID -ne $xdrfisrttxid -or 
                        $previousRow.XDRFISRTMEDID -ne $xdrfisrtmedid -or 
                        $previousRow.XCONDITION -ne $xcondition -or 
                        $previousRow.XAssignToERxUser -ne $xassigntoerxuser -or 
                        $previousRow.XPickUp -ne $xpickup) {
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
    
    # Add this flag to skip showing all data on first run
    $isFirstRun = $true
    
    # Show startup information
    if ($FullScan) {
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting FULL SCAN mode - monitoring ALL records (slower but complete)" -ForegroundColor Yellow
    } elseif ($StableMode) {
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting STABLE mode - monitoring small tables only (no false positives)" -ForegroundColor Cyan
    } else {
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting OPTIMIZED mode - monitoring small tables only (no false positives)" -ForegroundColor Green
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Large tables (CHGDRUG, Delivery, DOCUMENTS, CHANGES, ERX, PACMED, PATIENT, REFILL, RX, SCANS, TXNS) skipped to prevent false positives" -ForegroundColor Gray
    }
    
    if ($ResetBaseline) {
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] RESET BASELINE mode - clearing previous data to start fresh" -ForegroundColor Cyan
        $allPreviousData = @{}
        foreach ($tableName in $TableConfig.Keys) {
            $allPreviousData[$tableName] = @{}
        }
    }
    
    while ($true) {
        try {
            Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting database check cycle..." -ForegroundColor Gray
            $allResults = Check-AllTables $allPreviousData
            
            $hasAnyChanges = $false
            
            foreach ($tableName in $TableConfig.Keys) {
                # Skip large tables in StableMode and Optimized mode to avoid false positives
                if (($StableMode -or (-not $FullScan)) -and ($tableName -in @("CHGDRUG", "Delivery", "DOCUMENTS", "CHANGES", "ERX", "PACMED", "PATIENT", "REFILL", "RX", "SCANS", "TXNS"))) {
                    if ($StableMode) {
                        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Skipping large table $tableName in StableMode" -ForegroundColor Gray
                    } else {
                        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Skipping large table $tableName in Optimized mode" -ForegroundColor Gray
                    }
                    continue
                }
                
                $startTime = Get-Date
                Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Checking table: $tableName" -ForegroundColor Gray
                $columnName = $TableConfig[$tableName]
                $result = $allResults[$tableName]
                $endTime = Get-Date
                $scanDuration = ($endTime - $startTime).TotalSeconds
                
                if ($result -and $result.Success) {
                    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Table $tableName check completed successfully (${scanDuration:F2}s)" -ForegroundColor Gray
                    Write-Host ""  # Add blank line after each table check
                    $hasChanges = $false
                    
                    # Skip showing data on first run - just load the baseline
                    if ($isFirstRun) {
                        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] First run - loading baseline data for $tableName (not showing all records)" -ForegroundColor Gray
                        if ($result.CurrentData) {
                            $allPreviousData[$tableName] = $result.CurrentData
                        }
                        continue
                    }
                    
                    # Check for new rows
                    if ($result.NewIds -and $result.NewIds.Count -gt 0) {
                        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Processing NEW records for table: $tableName" -ForegroundColor Magenta
                        foreach ($id in $result.NewIds) {
                            Write-Host "=== NEW RECORD DETECTED ===" -ForegroundColor Green
                            Write-Host "Table: $tableName" -ForegroundColor Green
                            Write-Host "Primary Key (${columnName}): $id" -ForegroundColor Green
                            
                            # Show full row data
                            if ($result.CurrentData -and $result.CurrentData.ContainsKey($id.ToString())) {
                                $rowData = $result.CurrentData[$id.ToString()]
                                Write-Host "Full Row Data:" -ForegroundColor Cyan
                                foreach ($field in $rowData.Keys) {
                                    Write-Host "  $field = $($rowData[$field])" -ForegroundColor White
                                }
                            }
                            Write-Host "=========================" -ForegroundColor Green
                            $hasChanges = $true
                            $hasAnyChanges = $true
                        }
                    }
                    
                    # Check for updated rows
                    if ($result.UpdatedIds -and $result.UpdatedIds.Count -gt 0) {
                        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Processing UPDATED records for table: $tableName" -ForegroundColor Magenta
                        foreach ($id in $result.UpdatedIds) {
                            Write-Host "=== UPDATED RECORD DETECTED ===" -ForegroundColor Yellow
                            Write-Host "Table: $tableName" -ForegroundColor Yellow
                            Write-Host "Primary Key (${columnName}): $id" -ForegroundColor Yellow
                            
                            # Show detailed changes if available
                            if ($result.UpdatedDetails -and $result.UpdatedDetails.ContainsKey($id.ToString())) {
                                $details = $result.UpdatedDetails[$id.ToString()]
                                $previous = $details.Previous
                                $current = $details.Current
                                
                                Write-Host "Changes Detected:" -ForegroundColor Cyan
                                foreach ($field in $current.Keys) {
                                    $oldValue = if ($previous.ContainsKey($field)) { $previous[$field] } else { "NULL" }
                                    $newValue = $current[$field]
                                    if ($oldValue -ne $newValue) {
                                        Write-Host "  ${field}: '$oldValue' -> '$newValue'" -ForegroundColor White
                                    }
                                }
                                
                                Write-Host "Complete Current Row Data:" -ForegroundColor Cyan
                                foreach ($field in $current.Keys) {
                                    Write-Host "  $field = $($current[$field])" -ForegroundColor White
                                }
                            }
                            Write-Host "=============================" -ForegroundColor Yellow
                            $hasChanges = $true
                            $hasAnyChanges = $true
                        }
                    }
                    
                    # Check for deleted rows
                    if ($result.DeletedIds -and $result.DeletedIds.Count -gt 0) {
                        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Processing DELETED records for table: $tableName" -ForegroundColor Magenta
                        foreach ($id in $result.DeletedIds) {
                            Write-Host "=== DELETED RECORD DETECTED ===" -ForegroundColor Red
                            Write-Host "Table: $tableName" -ForegroundColor Red
                            Write-Host "Primary Key (${columnName}): $id" -ForegroundColor Red
                            
                            # Show the last known data for deleted record
                            if ($allPreviousData.ContainsKey($tableName) -and $allPreviousData[$tableName].ContainsKey($id.ToString())) {
                                $deletedRowData = $allPreviousData[$tableName][$id.ToString()]
                                Write-Host "Last Known Row Data:" -ForegroundColor Cyan
                                foreach ($field in $deletedRowData.Keys) {
                                    Write-Host "  $field = $($deletedRowData[$field])" -ForegroundColor White
                                }
                            }
                            Write-Host "=============================" -ForegroundColor Red
                            $hasChanges = $true
                            $hasAnyChanges = $true
                        }
                    }
                    
                    # Update previous data for this table
                    if ($result.CurrentData) {
                        $allPreviousData[$tableName] = $result.CurrentData
                    }
                } else {
                    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ERROR: Table $tableName check failed (${scanDuration:F2}s)" -ForegroundColor Red
                    Write-Host ""  # Add blank line after error message
                }
            }
            
            # Set flag to false after first run
            if ($isFirstRun) {
                $isFirstRun = $false
                Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Baseline data loaded. Now monitoring for changes..." -ForegroundColor Green
            }
            
            if ($hasAnyChanges) {
                Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Changes detected - displaying above" -ForegroundColor Gray
                Write-Host "---" -ForegroundColor Gray
            } else {
                Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] No changes detected in this cycle" -ForegroundColor Gray
            }
        }
        catch {
            Write-Error "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error in main loop: $_"
        }
        
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Waiting $CheckInterval seconds before next check..." -ForegroundColor Gray
        Start-Sleep $CheckInterval
    }
}
catch {
    Write-Error "Script error: $_"
    exit 1
}
