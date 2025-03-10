param(
 [string]$MuteMinutes
 )

$MonitoringServerIp=""
$MonitoringSite=""
$MonitoringServerUser=""
$MonitoringServerPassword=""
$MuteHostName=""


if($MuteMinutes -eq $null)
 {
     Write-Host "MuteMinutes was blank adding downtime for full week"
     $MuteMinutes = 10080
 }
 if($MuteMinutes -eq '')
 {
     Write-Host "MuteMinutes was blank adding downtime for full week"
     $MuteMinutes = 10080
}


$start_time=(get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$ts = New-TimeSpan -Minutes $MuteMinutes
$end_time=((get-date) + $ts).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$body="""start_time"": ""$start_time"", ""end_time"": ""$end_time"", ""recur"": ""fixed"", ""duration"": 0, ""comment"": ""Muted by Automation"", ""downtime_type"": ""host"", ""host_name"": ""$MuteHostName"""

$RESTRequest = @{
    Uri         = "http://$MonitoringServerIp/$MonitoringSite/check_mk/api/1.0/domain-types/downtime/collections/host"
    Method      = "Post"
    Body        = "{$body}"
    ContentType = "application/json"
    Headers     = @{ Authorization = "Bearer $MonitoringServerUser $MonitoringServerPassword" 
                     Accept = "application/json" 
}
}
Invoke-RestMethod @RESTRequest
