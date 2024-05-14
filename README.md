# wsl2_host_redirect
Step by step how to redirect hosts to wsl2

### Criação do script

**Crie um arquivo .ps1 com esse script na sua área de trabalho ou faça o download do arquivo**

```powershell
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

# Remove all previously Firewall Exception Rules
Invoke-Expression "Remove-NetFireWallRule -DisplayName 'TCP Ports' ";

# Allow ports through Windows Firewall
New-NetFireWallRule -DisplayName 'TCP Ports' -Direction Inbound -LocalPort 19000,19001,3333,4000 -Action Allow -Protocol TCP;
New-NetFireWallRule -DisplayName 'TCP Ports' -Direction Outbound -LocalPort 19000,19001,3333,4000 -Action Allow -Protocol TCP;

# Redirect ports to WSL2 ( 19000, 19001, 3333, 4000 )
netsh interface portproxy add v4tov4 listenport=19000 listenaddress=$windows_ip connectport=19000 connectaddress=$wsl_ip
netsh interface portproxy add v4tov4 listenport=19001 listenaddress=$windows_ip connectport=19001 connectaddress=$wsl_ip

netsh interface portproxy add v4tov4 listenport=3333 listenaddress=$windows_ip connectport=3333 connectaddress=$wsl_ip
netsh interface portproxy add v4tov4 listenport=4000 listenaddress=$windows_ip connectport=4000 connectaddress=$wsl_ip

# Show all newly proxied ports
Invoke-Expression "netsh interface portproxy show v4tov4"
```

### Agendando a execução do Script

**Abra o Agendador de Tarefas e clique em Criar Tarefa…**

![Untitled](https://github.com/hlgboot/wsl2_host_redirect/assets/69645018/1bd425e9-07a4-4e16-9f9a-b555854a38cc)
![Untitled](https://github.com/hlgboot/wsl2_host_redirect/assets/69645018/60ee60f4-5e09-4a5f-9316-58dc58d813fe)

**Dê um nome, habilite Executar com privilégios mais altos e configure para Windows 10**

![Untitled](https://github.com/hlgboot/wsl2_host_redirect/assets/69645018/26df0ec4-86c9-4797-95c5-05d5ffbb420a)

**Crie um novo disparador como esse**

![Untitled](https://github.com/hlgboot/wsl2_host_redirect/assets/69645018/91950d6b-ab03-435b-a9a1-797bae5d54b6)

**Crie uma nova ação e coloque o seguinte código trocando filePath pelo caminho completo ate o arquivo .ps1**

```powershell
Powershell.exe -ExecutionPolicy Bypass -f filePath
```

![Untitled](https://github.com/hlgboot/wsl2_host_redirect/assets/69645018/21e5b8f8-5da0-4582-8e0b-de62d39ed959)

### Variável ambiente

**Rode esse comando no terminal do wsl para gerar a variável ambiente com o IP base do Expo. A variável ambiente reseta em toda inicialização do wsl. Para configurar de forma permanente execute no terminal:**

```bash
code ~/.bashrc
```

**Isso vi abrir uma novo janela do VS Code. Ao final do arquivo adicione:**

```bash
export REACT_NATIVE_PACKAGER_HOSTNAME=seuipwindows
```

**Depois de salvar as alterações, rode esse comando no terminal para carregar a variável:**

```bash
source ~/.bashrc
```

**Rode esse comando para verificar a criação da variável ambiente**

```bash
echo $REACT_NATIVE_PACKAGER_HOSTNAME
```

**Pronto, agora suas portas já foram redirecionadas e você pode rodar sua aplicação sem problemas!**
