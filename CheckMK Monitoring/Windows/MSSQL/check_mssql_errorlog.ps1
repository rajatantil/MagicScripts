##This script works with Checkmk##
$templine = 0;
$errorlines = 0;
$filename = "C:\temp\alert_mssql.log"
$ERRORLOG = "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\ERRORLOG"

gc $ERRORLOG -read 1000 | % { $templine += $_.Length }; 

If (Test-Path -Path "$filename.curline" ) {
$nlines = get-content "$filename.curline"
}else
{
$nlines = 0;
}

If ( [int]$nlines -gt [int]$templine ) {
$nlines = 0;
} 

get-content $ERRORLOG | select -skip $nlines | Select-String -Pattern "Severity: 12","Severity: 13","Severity: 15","Severity: 16","Severity: 17","Severity: 18","Severity: 19","Severity: 20","Severity: 21","Severity: 22","Severity: 23","Severity: 24" -Context 0,1 | Add-Content -Path "$filename"

$nlines = $templine;

$nlines | Out-File -FilePath "$filename.curline"

gc "$filename" -read 1000 | % { $errorlines += $_.Length }; 


$omdout = (Get-Content -tail 100 "$filename") -join "\n"

If ([int]$errorlines -gt 0) {
	"2 check_mssql_errorlog - Critical $errorlines in $filename \n\n $omdout"
} 
else {
	"0 check_mssql_errorlog - All OK"
	}