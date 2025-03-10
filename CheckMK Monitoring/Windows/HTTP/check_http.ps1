$URL=""
$HTTP_Request = [System.Net.WebRequest]::Create("https://$URL")


$HTTP_Request.Timeout=6000;

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.GetResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {
    Write-Host "0 check_URL_$URL - is OK!"
}
Else {
    Write-Host "2 check_URL_$URL - $URL may be down, please check!"
}

# Finally, we clean up the http request by closing it.
If ($HTTP_Response -eq $null) { } 
Else { $HTTP_Response.Close() }
