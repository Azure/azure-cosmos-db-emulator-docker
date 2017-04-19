$addrObj = (Get-NetIPAddress -AddressFamily IPV4 -AddressState Preferred -PrefixOrigin Manual | Select IPAddress)
$addr = $addrObj.IPAddress
$result = "Emulator Endpoint: https://" + $addr + ":8081/"
echo $result
