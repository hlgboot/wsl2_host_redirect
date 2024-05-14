# wsl2_host_redirect
Step by step how to redirect hosts to wsl2

### Criação do script

**Crie um arquivo .ps1 com esse script na sua área de trabalho ou faça o download do arquivo**

[wsl2_host.ps1](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/fbcbfa31-9bc9-4b66-ac5e-72ba99e73dc8/wsl2_host.ps1)

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

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/cef6d236-9c4d-41eb-a7eb-a6646c916f15/Untitled.png)

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e8627886-fc83-49a3-aca8-0569e436f5a1/Untitled.png)

**Dê um nome, habilite Executar com privilégios mais altos e configure para Windows 10**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/300493b6-0dec-4526-8d7d-b96b159110e6/Untitled.png)

**Crie um novo disparador como esse**

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/d983bb3f-4f50-4864-8749-40003f052936/Untitled.png)

**Crie uma nova ação e coloque o seguinte código trocando filePath pelo caminho completo ate o arquivo .ps1**

```powershell
Powershell.exe -ExecutionPolicy Bypass -f filePath
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9704ec03-1276-49ef-b02b-94c05e56357e/Untitled.png)

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
