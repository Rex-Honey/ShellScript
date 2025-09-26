#  using triggers and get data from ChangeEvents table
#  command to run .\ok.ps1 -Server "DESKTOP-RBOPA1H\SQLEXPRESS" -Database "medidozeWeldon" -Table "ChangeEvents" -SqlUser "sa" -SqlPassword "dexter"
#  or
#  .\ok.ps1

while ($true) {
    cls
    Write-Host ("[{0}] dbo.ChangeEvents (TOP 100)" -f (Get-Date).ToString("s")) -ForegroundColor Cyan
    Import-Module SqlServer -ErrorAction SilentlyContinue
    Invoke-Sqlcmd -ServerInstance ".\SQLEXPRESS" -Database "medidozeWeldon" `
      -Query "SELECT TOP 100 * FROM dbo.ChangeEvents ORDER BY EventId" |
      Format-Table -AutoSize | Out-String -Width 4096 | Write-Host
    Start-Sleep -Seconds 10
  }