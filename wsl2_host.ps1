# Find WSL2 IP address
$wsl_ip = $(wsl hostname -I).Trim();
$windows_ip = '0.0.0.0';

if ( -Not $wsl_ip ) {
  Write-Output "IP address for WSL 2 cannot be found";
  exit;
}

Write-Output $wsl_ip
Write-Output $windows_ip

# Remove all previously proxied ports
Invoke-Expression "netsh int portproxy reset all"

# Remove Firewall Exception Rules
Invoke-Expression "Remove-NetFireWallRule -DisplayName 'TCP Ports' ";

# Allow Expo ports through Windows Firewall
New-NetFireWallRule -DisplayName 'TCP Ports' -Direction Inbound -LocalPort 19000,19001,3333,4000 -Action Allow -Protocol TCP;
New-NetFireWallRule -DisplayName 'TCP Ports' -Direction Outbound -LocalPort 19000,19001,3333,4000 -Action Allow -Protocol TCP;

# Redirect ports to WSL2 ( 19000, 19001, 3333, 4000 )
netsh interface portproxy add v4tov4 listenport=19000 listenaddress=$windows_ip connectport=19000 connectaddress=$wsl_ip
netsh interface portproxy add v4tov4 listenport=19001 listenaddress=$windows_ip connectport=19001 connectaddress=$wsl_ip

netsh interface portproxy add v4tov4 listenport=3333 listenaddress=$windows_ip connectport=3333 connectaddress=$wsl_ip
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=$windows_ip connectport=4000 connectaddress=$wsl_ip

# Show all newly proxied ports
Invoke-Expression "netsh interface portproxy show v4tov4"
