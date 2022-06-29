# Firewall

A configuração de Firewall é extremamente importante para bloquear acesso indevido ao servidor. Uma das formas mais rápidas e fáceis de fazer isso é utilizar a interface simples do Ubuntu: UFW. O UFW trabalha na camada logo acima do IPTABLES e este ainda é acessível, porém com a interface básica provida pelo Ubuntu, as configurações são muito mais fáceis.

1. Primeiro, verifique se o UFW está instalado:

   ```bash
   sudo ufw status
   ```

   > A instrução acima deve retornar `Status: inactive`.  Caso o UFW não esteja instalado, execute `sudo apt-get install ufw`.

2. Altere as configurações padrões do UFW, executando as operações abaixo:

   ```bash
   # Autoriza todas as conexões de saída
   sudo ufw default allow outgoing
   
   # Bloqueia todas as conexões de entrada
   sudo ufw default deny incoming
   ```

3. Configure as regras padrões:

   ```bash
   # Libere a porta SSH personalizada
   sudo ufw allow <port>/tpc
   
   # Libere o acesso HTTP/HTTPS
   sudo ufw allow http
   sudo ufw allow https
   ```

   > ⚠️ Tenha muito cuidado, libere a porta correta para a entrada SSH, a mesma definida em `/etc/ssh/sshd_config`. Não feche o terminal até habilitar o UFW e testar a conexão em outro terminal.

4. Habilite o log do UFW:

   ```bash
   # Habilita o log do UFW
   # > low: Registra todos os pacotes bloqueados e permitidos pelas políticas
   # > medium: low + registra os pacotes não incluídos nas políticas
   # > high: medium + registras todos as limitações aplicadas
   # > full: todos os eventos
   sudo ufw logging medium
   ```

5. Habilite o UFW:

   ```bash
   sudo ufw enable
   ```

6. Verifique o status do UFW:

   ```bash
   sudo ufw status verbose
   sudo service ufw status
   ```

7. Entre em outro terminal e tente fazer a conexão SSH novamente. Se estiver tudo okay, prossiga. Do contrário, desabilite o UFW com `ufw disable` e reveja as suas regras com `sudo ufw status verbose`.

## Regras do Firewall

Todas as regras são aplicadas em portas e/ou IPs. As portas podem ser definidas como:

- `<port>`: Porta no protocolo UDP e TCP;
- `<port>/tcp`: Porta apenas no protocolo TCP;
- `<port>/udp`: Porta apenas no protocolo UDP;
- `<port>:<port>`: intervalo de porta no protocolo UDP e TCP;
- `<port>:<port>/tcp`: Intervalo de porta apenas no protocolo TCP;
- `<port>:<port>/udp`: Intervalor de porta apenas no protocolo UDP;

| Descrição                    | Comando                                                      |
| ---------------------------- | ------------------------------------------------------------ |
| Permitir porta               | `sudo ufw allow <port>`; `sudo ufw allow <port>/tcp`; `sudo ufw allow <port>/udp` |
| Permitir intervalo de porta  | `sudo ufw allow <port>:<port>`; `sudo ufw allow <port>:<port>/tcp`; `sudo ufw allow <port>:<port>/udp` |
| Permitir um endereço de IP   | `sudo ufw allow from <ip>`                                   |
| Permitir a subnet do IP      | `sudo ufw allow from <ip>/<subnet>`                          |
| Permitir porta para IP       | `sudo ufw allow from <ip> to any port <port>`                |
| Bloquear porta               | `sudo ufw deny <port>`; `sudo ufw deny <port>/tcp`; `sudo ufw deny <port>/udp` |
| Bloquear intervalo de porta  | `sudo ufw deny <port>:<port>`; `sudo ufw deny <port>:<port>/tcp`; `sudo ufw deny <port>:<port>/udp` |
| Bloquear um endereço de IP   | `sudo ufw deny from <ip>`                                    |
| Bloquear a subnet do IP      | `sudo ufw deny from <ip>/<subnet>`                           |
| Bloquear porta para IP       | `sudo ufw deny from <ip> to any port <port>`                 |
| Ver regras numeradas         | `sudo status numbered`                                       |
| Deletar uma regra por número | `sudo delete <number>`                                       |
| Deletar uma regra            | `sudo delete <rule>`                                         |

## Logs

Para que os logs do UFW funcionem corretamente, certifique-se que o `rsyslog` está habilitado com o comando `sudo service rsyslog status`.  Todos os logs do UFW estarão disponíveis em `/var/log/` e utilizarão a nomenclatura `ufw*`.

Cada registro no log conterá os seguintes campos:

- **IN=** Este campo mostra o dispositivo para tráfego de entrada.
- **OUT=** Este campo mostra o dispositivo para tráfego de saída.
- **MAC=** Este campo mostra o endereço MAC do dispositivo.
- **SRC=** Este campo exibe um endereço IP de origem da conexão.
- **DST=** Exibe o endereço IP de destino de uma conexão.
- **LEN=** Este campo mostra o comprimento do pacote.
- **PREC=**Este campo mostra o Tipo de Precedência do Serviço.
- **TTL=** Este campo mostra o tempo de vida.
- **ID=** Este campo mostra um ID exclusivo para o datagrama IP que é compartilhado por fragmentos do mesmo pacote.
- **PROTO=** Este campo mostra o protocolo utilizado.