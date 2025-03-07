# Set required SQL related services to "Automatic" or "Automatic (Delayed Start)"
# Set other SQL services to "Disabled"

$output = get-wmiobject -Class win32_service | where {$_.name -like 'MSSQLServer' -OR $_.name -like 'MSSQL$*' -or $_.name -like '*SQLA*' -or $_.name -like '*SQL*' -and $_.state -like 'Stopped' -and $_.StartMode -notlike "Disabled"}

if ($output)
{
  "2 check_sql_service - Services not running :- " + ($output.Name -join ' ')
}
else 
{
  "0 check_sql_service - All OK"
}
