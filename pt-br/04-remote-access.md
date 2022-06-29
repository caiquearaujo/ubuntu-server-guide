# Configurações de Acesso Remoto

## Grupos e Usuários

Uma das tarefas iniciais mais importantes é verificar todos os grupos e usuários ativos no momento. O ideal é sempre manter a menor quantidade possível de ambos. Essa estratégia ajuda a manter o sistema limpo e aumenta o nível de segurança.

> Para verificar os usuários do sistema execute `sudo getent passwd` e para verificar os grupos do sistema  execute `sudo getent group`.

Para verificar os usuários e/ou grupos que podem ser descartados, você pode utilizar o script [check-users-n-groups.sh](../scripts/check-users-n-groups.sh). Adicione a permissão de execução a ele (`+x`) e execute-o.

> Se você identificar potenciais grupos desnecessários, utilize o comando `groupdel <group>` e para usuários execute  `userdel -r <user>`.

### Grupos Administrativos

Para gerenciar melhor a administração do sistema, vamos criar três grupos, são eles:

- `sshvps`: Para usuário que terão acesso via SSH;

  > Um usuário com acesso ao shell completo, inclusive ao FTP e MySQL via SSH Tunnel.

- `ftpvps`: Para usuários que terão acesso ao FTP;

  > Um usuário com acesso travado em sua pasta `<home>` e apenas para finalidade de uso do FTP.

- `sqlvps`: Para usuários que terão acesso ao MySQL via SSH Tunnel.

  > Um usuário com acesso ao MySQL vis SSH Tunnel para a porta 3306 local, sem expor o MySQL publicamente.

Crie cada um dos grupos acima:

```bash
sudo groupadd sshvps
sudo groupadd ftpvps
sudo groupadd sqlvps
```

## Usuários

É importante ter uma consistência na criação dos usuários, procure organiza-los da seguinte forma: `Adminstradores -> Outros (Internos) -> Outros (Externos)`.

- Os usuários administradores devem possuir acesso as operações root, portanto integram o grupo `sudo`;

  > A nomenclatura destes usuários é `master<name>`.

- Os demais usuários internos podem possuir restrições para manipular apenas os serviços que necessitam, como é o caso de usuários para o FTP, para acesso ao MySQL, etc, não vão integrar o grupo `sudo`;

  > A nomenclatura destes usuários é `internal<name>`.

- Os usuários externos podem ou não possuir restrições de manipulação no terminal e podem ou não integrar o grupo `sudo` dependendo da necessidade.

  > A nomenclatura destes usuários é `external<name>`.

### Criação de Usuário

1. Crie um novo usuário administrativo, para exemplo o nome do usuário será “Caique”:

   ```bash
   sudo adduser mastercaique
   ```

2. Crie uma variável de ambiente temporária com o nome do usuário recém criado:

   ```bash
   CURR_USER=mastercaique
   ```

3. Execute a sequência de comandos para preparar o acesso SSH:

   ```bash
   # Crie a pasta .ssh e altere suas permissões
   sudo mkdir -p /home/$CURR_USER/.ssh
   sudo chmod 700 /home/$CURR_USER/.ssh
   # Crie o arquivo authorized_keys com as chaves autorizadas e altere suas permissões
   sudo touch /home/$CURR_USER/.ssh/authorized_keys
   sudo chmod 600 /home/$CURR_USER/.ssh/authorized_keys
   ```

4. Corrija as permissões da pasta:

   ```bash
   # Corrige as permissões da pasta home
   sudo chown -R $CURR_USER:$CURR_USER /home/$CURR_USER
   sudo chown root:root /home/$CURR_USER
   sudo chmod 755 /home/$CURR_USER
   sudo chown -R $CURR_USER:$CURR_USER /home/$CURR_USER
   ```

5. Associe o usuário recém criado ao grupo para usuários administradores:

   ```bash
   sudo usermod -aG sshvps,sudo $CURR_USER
   ```

6. Verifique os grupos associados com o comando `sudo id mastercaique`.

> Se preferir, você também pode utilizar o script [create-user.sh](../create-user.sh) para executar as instruções acima em sequência. Utilize-o da seguinte forma: `./create-user.sh <user>`. Depois, adicione os grupos ao usuário.

## Chaves Públicas e Privadas

Cada usuário que realize acesso remoto ao servidor, precisará necessariamente de uma chave pública/privada. Esse arquivo substituirá a senha durante o acesso a máquina do servidor. Um usuário pode ter quantas chaves pública/privada ele quiser, desde que sempre ao acessar o servidor ele utilize essas chaves.

No `setup` que aplicaremos:

1. O usuário deve criar a chave pública e privada em sua máquina;
2. Deverá compartilhar com o servidor a chave pública;
3. O SSH do servidor irá solicitar a chave privada e verificar se é compatível;
4. O acesso será liberado e as operações `sudo` exigirão senha.

### Criação de um par de chaves

Para os softwares com interface, crie uma chave com os seguintes parâmetros:

1. Criptografia `RSA-2048`;
2. Comentário identificando a chave `<user>@<hostname>`;
3. Defina uma senha para a chave privada;
4. Salve o arquivo `.pub` (chave pública) e o arquivo `.ppk` (chave privada) em um local seguro;
5. O conteúdo do arquivo `.pub` que será compartilhado e instalado no servidor, enquanto o conteúdo do arquivo `.ppk` será enviado ao realizar a conexão remota.

Para terminais, crie uma chave com os seguintes parâmetros:

```bash
ssh-keygen -t ed25519 -C "<user>@<hostname>" -f ~/.ssh/id_ed25519 -P [password]
```

> Note que, por estar disponível na maioria dos sistemas via terminal, utilizamos o algoritmo **Ed25519** para criação da chave. Este é um algoritmo de assinatura de chave pública moderno e seguro que traz uma eficiência maior e resistências a vários tipos de ataques.

### Compartilhamento da Chave Pública

Antes de compartilhar a chave pública, o usuário deve existir na máquina de destino e também deve possuir a estrutura de pasta `.ssh` em sua pasta `<home>`. Verifique se o usuário possuí, caso contrário execute:

```bash
# Crie a pasta .ssh e altere suas permissões
sudo mkdir -p /home/$CURR_USER/.ssh
sudo chmod 700 /home/$CURR_USER/.ssh
# Crie o arquivo authorized_keys com as chaves autorizadas e altere suas permissões
sudo touch /home/$CURR_USER/.ssh/authorized_keys
sudo chmod 600 /home/$CURR_USER/.ssh/authorized_keys
```

#### Inserção da chave pública

Por segurança é ideal que apenas um usuário de acesso root insira a chave pública autorizada. Para isso, solicite a chave pública do usuário e adicione no arquivo `authorized_keys`:

```bash
echo '<publickey>' >> /home/$CURR_USER/.ssh/authorized_keys
```

## Mensagem de Aviso da Conexão SSH

Quando uma conexão SSH é estabelecida, um banner informativo será exibido. Por padrão, este banner mostrará a distribuição do Linux. É interessante colocar uma mensagem personalizada. Para isso:

1. Edite o banner disponível no arquivo:

   ```bash
   sudo nano /etc/issue.net
   ```

2. Altere as permissões do banner:

   ```bash
   sudo chmod 0644 /etc/issue.net
   sudo chown root:root /etc/issue.net
   ```

O conteúdo recomendado para o banner, está abaixo:

```bash
 This server is a property of <company>.

 Unauthorized use of this system is an offence under the Computer Misuse Act 
 1990. By using this system you agree that your activity may be continuously 
 monitored and that you will comply with the conditions of use. 
 
 All accesses are logged.
```

## Configuração do SSH

1. Faça backup das configurações do SSH:

   ```bash
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
   ```

2. Edite o arquivo de configuração do SSH de acordo:

   ```bash
   # PORT
   # Defina uma porta entre 10000 e 65000
   Port <port>
   
   # PROTOCOL
   # Utilize o protocolo mais recente
   Protocolo 2
   
   # ADDRESS FAMILY
   # Force a trabalhar com IPv4
   # any -> IPv4, IPv6
   # inet -> IPv4
   # inet6 -> IPv6
   AddressFamily inet
   
   # SYSLOG FACILITY
   # Classifique os logs do SSH como AUTH
   SyslogFacility AUTH
   # LOG LEVEL
   # Defina o nível do log para "INFO"
   LogLevel INFO
   
   # LOGIN GRACE TIME
   # Retém o login inválido por um minuto antes de desconectá-lo
   LoginGraceTime 1m
   
   # PERMIT ROOT LOGIN
   # Para manter o sistema aberto, por enquanto
   # mantenha o login via root autorizado
   PermitRootLogin yes
   
   # Garante que as permissões do usuário estão corretas
   StrictModes yes
   
   # MAXAUTHTRIES
   # Permite uma quantidade de tentativas de conexão,
   # após isso as próximas tentativas serão adicionadas em log.
   MaxAuthTries 3
   # MAX SESSIONS
   # Permite uma quantidade máxima de sessões ativas
   MaxSessions 6
   
   # AUTHENTICATION METHODS
   # Refere-se a todos os métodos que um usuário precisa passar
   # para ser autenticado, neste caso apenas pelo método publickey
   AuthenticationMethods publickey
   
   # PUBKEY AUTHENTICATION
   # Especifica que o método de conexão por chaves é permitido
   PubkeyAuthentication yes
   
   # HOST BASED AUTHENTICATION
   # Força o usuário a se autenticar, previndo que a autenticação 
   # por máquina aconteça
   HostbasedAuthentication no
   # IGNORE RHOSTS
   # Ignora os hosts já autenticados, forçando sempre 
   # o usuário a autenticar a cada nova conexão
   IgnoreRhosts yes
   
   # PASSWORD AUTHENTICATION
   # Especifica que o método de conexão por senha não é permitido
   PasswordAuthentication no
   
   # PERMIT EMPTY PASSWORD
   # Reforça que, mesmo em excessões de acesso por senha, a senha é obrigatória
   PermitEmptyPasswords no
   
   # CHALLANGE RESPONSE AUTHENTICATION
   # Especifica que o método de conexão por desafio não é permitido
   ChallengeResponseAuthentication no
   
   # PERMIT USER ENVIRONMENT
   # Desabilita a capacidade do usuário de alterar as configurações do SSH
   # em ~/.ssh/environment ou ~/.ssh/authorized_keys
   PermitUserEnvironment no
   
   # MACS
   # Força o SSH a utilizar algortimos seguros para as mensagens de código de autorização
   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
   
   # USE PAM
   # Habilita o Pluggable Authentication Modules
   # aumentando a camada de segurança das autenticações
   # e permitindo módulos customizados como a autenticação de dois fatores
   UsePAM yes
   
   # X11 FORWADING
   # Desabilita conexão remota por GUI
   X11Forwarding no
   
   # PRINT MOTD
   # Exibe a Message of the Day do sistema
   # que está em /etc/motd ou /etc/update-motd.d
   PrintMotd yes
   
   # PRINT LAST LOG
   # Exibe informações de data/hora do último login realizado
   PrintLastLog yes
   
   # TCP KEEP ALIVE
   # Enviar mensagens de TCP keepalive para o usuário conectado,
   # garantindo que a conexão está ativa e fechando a conexão
   # automaticamente quando inativa
   TCPKeepAlive yes
   
   # CLIENT ALIVE INTERVAL
   # (Recurso utilizado com o protocolo 2 do SSH)
   # Define um intervalo de tempo limite para não receber uma
   # resposta do cliente
   ClientAliveInterval 60
   
   # CLIENT ALIVE COUNT MAX
   # Quantos pacotes de inatividade devem ser enviados ao cliente
   # antes de recusar e fechar uma conexão.
   ClientAliveCountMax 60
   
   # !! O ClientAliveInterval e o ClientAliveCountMax fazem parte do
   # !! TCPKeepAlive, eles controlam como um pacote para validar que o cliente
   # !! está ativo deve se comportar. Se eu definir ClientAliveInterval para 60 segundos
   # !! e o ClientAliveCountMax para 10 pacotes. Isso significa que, enquanto o cliente
   # !! estiver inativo (deixado o terminal aberto) o SSH irá enviar a cada 60 segundos
   # !! um pacote até o limite de 10 pacotes. Quando enviar todos os pacotes, se ainda
   # !! não obtiver uma resposta, então encerrará a conexão por inatividade.
   # !! ClientAliveInterval e ClientAliveCountMax requerem "TCPKeepAlive yes" e "Protocol 2"
   
   # MAX STARTUPS
   # Indica o número máximo de solicitações de conexão com o SSH
   # Isso faz com que não permita muitas tentativas simultâneas de autenticação
   # e garante que vá liberando aos poucos conforme as pessoas se autenticam.
   # Inicia com 3 conexões, com uma chance de 50% de recusá-las 
   # até chegar no limite de 6 conexões ativas.
   MaxStartups 3:50:6
   
   # BANNER
   # Banner de aviso para aparecer antes do usuário se autenticar
   # edite o arquivo /etc/issue.net com a mensagem desejada
   Banner /etc/issue.net
   
   # SUBSYSTEM
   # Define um subsistema (atalho) do SSH para ser executado ao utilizar a opção
   # -s do SSH. O subsistema abaixo, ao receber a informação de SFTP, irá executar
   # o internal-sftp (parte do pacote do ssh), por exemplo.
   
   # Ao requistar por sftp, executará o internal-sftp
   # ssh <user>@<ip> -s sftp
   Subsystem sftp internal-sftp
   
   # MATCH
   # A instrução Match configura regras específicas para User, Group, Host ou Address
   
   # !! Seleciona o grupo sftpvps e cria regras específicas para ele
   Match Group ftpvps
   	# Força a utilização do comando internal-sftp ao ser autenticado
       ForceCommand internal-sftp
       # Força o usuário a entrar apenas na pasta %h (sua pasta home)
       ChrootDirectory %h
       # Desabilita a função Tunnel do SSH
       PermitTunnel no
       # Desabilita o redirecionamento por agente
       AllowAgentForwarding no
       # Desabilita o redirecionamento de porta
       AllowTcpForwarding no
   
   # ALLOW GROUPS
   # Permite os grupos de usuário que poderão acessar o SSH
   AllowGroups sshvps, ftpvps, sqlvps
   ```

3. Altere as permissões do arquivo de configuração do SSH:

   ```bash
   sudo chmod 0600 /etc/ssh/sshd_config
   sudo chown root:root /etc/ssh/sshd_config
   ```

4. Verifique se o SSH está ouvindo corretamente a porta padrão antes de reiniciar:

   ```bash
   sudo netstat -tulnp | grep ssh
   ```

5. Reinicie o serviço SSH e verifique o status após a reinicialização:

   ```bash
   sudo service ssh restart
   sudo systemctl status ssh
   ```

   > Se houverem erros, provavelmente alguma configuração foi preenchida erroneamente, verifique com `sudo journalctl -xe`, corrija e reinicie o serviço SSH novamente.

6. Garanta que o serviço está sendo ouvido na nova porta definida:

   ```bash
   sudo netstat -tulnp | grep ssh
   ```

7. Tente realizar a conexão remota com o usuário administrativo criado previamente:

   ```bash
   ssh <user>@<ip> -p <port> [-i <pub_key_path>]
   ```

8. Caso a conexão tenha dado certo, continue para os próximos passos.

### Desabilitar acesso root

Agora que configuramos o SSH, podemos seguir adiante e bloquear o acesso com usuário root e autorizar o acesso apenas aos grupos selecionados.

> ⚠️ Não prossiga antes de criar um usuário administrativo que possua privilégio **sudo** e estar certo da senha do usuário administrativo. Se não for o caso, crie um novo usuário administrativo seguro.

1. Edite o arquivo de configuração do SSH de acordo:

   ```bash
   # PERMIT ROOT LOGIN
   # Impede que o usuário root conecte-se, mesmo que ele tenha chaves.
   PermitRootLogin no
   
   # >> Adicione ao final do arquivo
   # DENYS
   # Bloqueia o usuário root
   DenyUsers root
   # Bloqueia usuários com grupo de acesso root
   DenyGroups root
   
   # ALLOWS
   # Permite todos os grupos válidos
   AllowGroups sshvps ftpvps sqlvps
   ```

2. Reinicie o serviço SSH e verifique o status após a reinicialização:

   ```bash
   sudo service ssh restart
   sudo systemctl status ssh
   ```

   > Se houverem erros, provavelmente alguma configuração foi preenchida erroneamente, verifique com `sudo journalctl -xe`, corrija e reinicie o serviço SSH novamente.

3. Tente realizar a conexão remota com o usuário administrativo criado previamente:

	```bash
	ssh <user>@<ip> -p <port> [-i <pub_key_path>]
	```

4. Migre para o usuário `root`:

	```bash
	sudo su
	```

5. Force o comando `sudo` utilizar senha executando o comando `sudo visudo` e certificando que a linha abaixo não contenha a expressão `NOPASSWD:`:

	```bash
	%sudo   ALL=(ALL:ALL) ALL
	```

6. Execute o comando `whoami` e certifique-se de estar no usuário `root`, então execute o comando `passwd --lock root` para remover a senha completamente;

7. Por fim, tecle `exit` para voltar ao usuário administrativo e execute novamente `sudo su` para certificar que a senha do usuário administrativo é solicitada.

### Autenticação de Dois Fatores

> ⚠️ A autenticação de dois fatore redobra a segurança do sistema, mas deve ser utilizada com muito cuidado. Como você utiliza uma aplicação externa para gerar o código, sem acesso à aplicação o acesso ao servidor será perdido. **Tenha muita atenção aos passos a seguir**.

1. Crie um usuário administrativo global do servidor, sem acesso ssh, mas com permissão `sudo`:

	> ⚠️ Defina uma senha segura com pelo menos 64 caracteres e mantenha salva, nunca perda a senha.

	```bash
	CURR_USER=<user>
	sudo adduser $CURR_USER
	
	sudo chown -R $CURR_USER:$CURR_USER /home/$CURR_USER
	sudo chown root:root /home/$CURR_USER
	sudo chmod 755 /home/$CURR_USER
	sudo chown -R $CURR_USER:$CURR_USER /home/$CURR_USER
	
	sudo usermod -aG sudo
	sudo id $CURR_USER
	```

	> Antes de prosseguir, migre para o usuário criado com `su $CURR_USER` e tente executar o comando `sudo`. Só avance caso tudo esteja okay.

2. Crie um novo grupo `twofa` para as contas que terão autenticação de dois fatores associadas:

	```bash
	sudo groupadd twofa
	```

3. Instale o módulo de autenticação do Google:

	```bash
	sudo apt-get install libpam-google-authenticator
	```

4. Inicialize a configuração do Google Authenticator:

	```bash
	google-authenticator
	```

5. Altere os módulos de autenticação do SSH em `sudo nano /etc/pam.d/common-auth` adicionando a linha abaixo ao final do arquivo:

	```bash
	auth	required	pam_google_authenticator.so	nullok
	```

6. Edite as configurações do SSH com os seguintes valores:

	```bash
	ChallengeResponseAuthentication yes
	
	Match Group twofa
		AuthenticationMethods publickey,keyboard-interactive
	```

7. Reinicie o serviço SSH e ative-o:

	```bash
	sudo service ssh restart
	sudo service ssh status
	```

8. Execute qualquer comando `sudo` e verifique se a solicitação foi feita.