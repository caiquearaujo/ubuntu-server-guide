# Configurações de E-mail

O e-mail é uma das coisas mais delicadas de um servidor. Afinal, devido a necessidade de entregar e-mail a outras pessoas (servidores), as máquinas são classificadas com um grau de risco e seus IP são marcados. Por essa razão, os e-mails vão para o SPAM. Devido ao comportamento do servidor de e-mail dentro de uma máquina.

A fim de evitar isso, é ideal adotas duas principais estratégias:

1. Contratar um servidor de e-mail do Umbler, da Microsoft ou do Google, para os e-mails corporativos e pessoais associados ao domínio;

2. Registrar o domínio em um **SMTP Relay** cuja a função é apenas enviar e-mails. Utilizamos esse processo para enviar e-mails automatizados do website ou plataforma que utilizamos. Essa ferramenta auxilia o processo e garante que não entremos na faixa de SPAM.

   > Um SMTP Relay recomendado é o **MailJet**.

A função da máquina com as estratégias acima será apenas realizar o envio de e-mail, não irá funcionar como uma caixa de mensagens. Nosso objetivo é apenas enviar notificações, e-mail marketing, etc, a partir da máquina e apontar esses envios para e-mails do domínio.

## Postfix

1. Instale o Postfix na máquina:

   ```bash
   sudo apt-get install libsasl2-modules postfix mailutils
   ```

2. Caso a tela de configuração não apareça, execute `sudo dpkg-reconfigure postfix` e defina:

   - System Mail Name (Nome do Serviço de E-mail): O mesmo nome de domínio da sua máquina;
   - Mail Server Configuration Type: Internet site.

3. Edite o arquivo de configuração do Postfix ` sudo nano /etc/postfix/main.cf` com os seguintes dados:

   ```bash
   # Configurações base do SSL, depois migraremos para um certificado emitido por Let's Encrypt
   smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
   smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
   smtpd_tls_security_level=may
   
   smtp_tls_CApath=/etc/ssl/certs
   smtp_tls_security_level=may
   smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache
   
   # Habilitar o protocolo TSL
   smtpd_use_tls=yes
   
   # Configura as políticas padrões de envio de e-mail
   # permit_mynetworks -> Permite as redes do servidor
   # permit_sasl_authenticated -> Permite a layer de segurança para autenticação simples
   # check_recipient_access -> Valida os perfis de acesso do recipiente
   # hash:/etc/postfix/sender_address -> Lista os perfis de envio
   # defer_unauth_destination -> Rejeita requisições com códigos de erros não permanentes
   smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated check_recipient_access hash:/etc/postfix/sender_address defer_unauth_destination
   
   # Restrições dos endereços de envio
   # check_sender_access -> Verifica o e-mail que está enviando
   # hash:/etc/postfix/sender_address -> Lista os perfis de envio
   smtpd_sender_restrictions = check_sender_access hash:/etc/postfix/sender_address
   
   # Nome do hostname do servidor
   myhostname = <hostname>
   
   # Nome do domínio principal do servidor
   mydomain = <domain>
   
   # Mapa de aliases para os usuários
   alias_maps = hash:/etc/aliases
   
   # Dados de aliases para os usuários
   alias_database = hash:/etc/aliases
   
   # Pasta origem de envio do e-mail
   myorigin = /etc/mailname
   
   # Lista de redes confiáveis
   mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
   
   # Lista de domínios que são entregues através do transporte de entrega de e-mail `local_transport`
   # quando esses domínios forem identificados o envio será local para o usuário associado
   mydestination = localhost.$mydomain, localhost, $myhostname
   
   # Limite da caixa de entrada de e-mail
   mailbox_size_limit = 0
   
   # Delimitador de organização do recipiente interno
   recipient_delimiter = +
   
   # O Postfix será apenas um redirecionador de e-mails
   inet_interfaces = loopback-only
   
   # Habilita os protocolos de ipv4 e ipv6
   inet_protocols = all
   
   # Aliases com endereços e domínios
   virtual_alias_map = hash:/etc/postfix/virtual
   
   # Aliases canonicos
   canonical_maps = hash:/etc/postfix/canonical
   
   # @@ CONFIGURAÇÕES RELAY (para MailJet e similares)
   
   # Habilita a camada de segurança para autenticação simples
   smtp_sasl_auth_enable = yes
   # Permite senhas de texto plano
   smtp_sasl_security_options = noanonymous
   # Mapeia as senhas das contas de envio
   smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
   # Mapeia os hosts dos relays utilizados
   sender_dependent_relayhost_maps = hash:/etc/postfix/sender_relay
   # Explicita que a autenticação é necessária
   smtp_sender_dependent_authentication = yes
   
   # @@ CONFIGURAÇÕES DE ENVIO POR SMTP PADRÃO
   # @@ caso não queira utilizar o Mailjet
   # @@ e deseje utlizar a Umbler, 
   # @@ mas o risco de SPAM é alto
   # -> Só faça abaixo se não desejar usar um relay
   
   # Host SMTP por onde os e-mail serão enviados
   relayhost = [smtp.umbler.com]:587
   # Habilita a camada de segurança para autenticação simples
   smtp_sasl_auth_enable = yes
   # Permite senhas de texto plano
   smtp_sasl_security_options = noanonymous
   # Mapeia as senhas das contas de envio
   smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
   # Classes de envio
   sender_canonical_classes = envelope_sender, header_sender
   ```

Agora, vamos configurar os relays do SMTP que vão deixar explícito todos os e-mails (ou domínios) que podem enviar e-mail a partir dessa máquina, os arquivos que iremos editar são separados em:

- `sender_address`: com endereços de e-mails que iremos utilizar;
- `sender_relay`: com os relays associados aos domínios/e-mails;
- `sasl_password`: com os usuários/senhas.

1. Edite o arquivo `sudo nano /etc/postfix/sender_relay` com os seguintes dados:

   ```bash
   # !! IMPORTANTE
   # Para ambos, tanto MailJet e similares ou servidores de SMTP já existentes,
   # sempre será necessário que o e-mail que envia a mensagem exista! Caso ele
   # não exista no servidor onde ele está sendo autenticado, não será enviado
   
   # @@ CONFIGURAÇÕES RELAY (para MailJet e similares)
   
   # Nesse formato, você autentica somente os domínios associados a máquina
   # seguindo a estrutura @<domínio> <host>:<port>
   @domain.com in-v3.mailjet.com:587
   
   # Acima, você autorizou qualquer e-mail do domínio a enviar via MailJet,
   # mas você pode mudar o host conforme o usuário, essencial quando você
   # quer autenticar uma conta em um outro servidor
   email@domain.com in-v3.mailjet.com:587
   
   # @@ CONFIGURAÇÕES DE ENVIO POR SMTP PADRÃO
   
   # Nesse formato, você PRECISA autenticar todos os e-mail que serão 
   # autorizados a enviar e-mails a partir desta máquina, por exemplo:
   email@domain.com smtp.umbler.com:587
   ```

2. Edite o arquivo `sudo nano /etc/postfix/sasl_password` com as senhas associadas as relays definidos anteriormente:

   ```bash
   # !! IMPORTANTE
   # !! Todos os endereços configurados acima, também deve estar configurados
   # !! aqui, mas agora com a senha associada
   
   # @@ CONFIGURAÇÕES RELAY (para MailJet e similares)
   
   # Nesse formato a autenticação é realizada por uma chave e um segredo
   # associado aos relays que nesse caso são os domínios ou os usuários
   # e operam no seguinte formato:
   @<domínio> <key>:<secret>
   <user>@<domínio> <key>:<secret>
   
   # @@ CONFIGURAÇÕES DE ENVIO POR SMTP PADRÃO
   
   # Nesse formato, você colocará o host SMPT em evidência e colocará
   # o e-mail e a senha para realizar a conexão
   [<host>]:<port> <email>:<password>
   ```

3. Crie alias para os e-mails quando necessário no arquivo `sudo nano /etc/postfix/virtual`:

   ```bash
   <user>@domain.com <user>@anotherdomain.com
   ```

4. Mapeie os usuários locais do Linux para um endereço de e-mail válido editando o arquivo `sudo nano /etc/postfix/canonical`:

   ```bash
   your-login-name	your-account@your-isp.com
   ```

5. Clone o hostname da máquina para o nome do servidor de e-mail somente se o hostname for igual ao domínio:

   ```bash
   sudo hostname --fqdn > /etc/mailname
   ```

6. Gere o mapa dos relays e das senhas:

   ```bash
   sudo postmap /etc/postfix/sasl_password /etc/postfix/sender_relay /etc/postfix/virtual /etc/postfix/canonical
   ```

7. Corrija as permissões dos arquivos:

   ```bash
   sudo chmod 0600 /etc/postfix/sasl_password /etc/postfix/sasl_password.db /etc/postfix/sender_relay /etc/postfix/sender_relay.db /etc/postfix/virtual /etc/postfix/canonical /etc/postfix/virtual.db /etc/postfix/canonical.db
   sudo chown root:root /etc/postfix/sasl_password /etc/postfix/sasl_password.db /etc/postfix/sender_relay /etc/postfix/sender_relay.db /etc/postfix/virtual /etc/postfix/canonical /etc/postfix/virtual.db /etc/postfix/canonical.db
   ```

8. Recarregue o serviço do Postfix:

   ```bash
   sudo service postfix reload
   ```

9. Envie um e-mail de teste:

   ```bash
   echo "body of your email" | mail -s "This is a Subject" -a "From: from@domain.com" to@domain.com
   ```

10. Verifique o log de e-mail:

    ```bash
    cat /var/log/mail.log | less
    ```

11. Por fim, edite os aliases para os usuários do Linux com `sudo nano /etc/aliases` para que os e-mail sejam enviados corretamente:

    ```bash
    mailer-daemon: postmaster
    postmaster: root
    nobody: root
    hostmaster: root
    usenet: root
    news: root
    webmaster: root
    www: root
    ftp: root
    abuse: root
    noc: root
    security: root
    www-data: root
    root: your_email_address
    
    # Só adicionar aliases quando
    # -> O hostname da máquina for diferente do domínio principal
    # -> O nome de usuário da máquina não possuí um endereço de e-mail
    
    # root -> root@servidor-aula => server@piggly.com.br
    # root -> root@agenteweb.com.br
    
    # Umbler -> server@piggly.com.br => (alias) admin@piggly.com.br root@piggly.com.br
    # Mailjet -> server@piggly.com.br admin@piggly.com.br  root@piggly.com.br
    # Hostname -> piggly.com.br                                                                                                                                       
    # mastercaique -> não tenho mastercaique@piggly.com.br
    # mesmo que o hostname fosse piggly.com.br
    mastercaique: caique@piggly.com.br
    ```

12. Atualize os aliases:

    ```bash
    sudo newaliases
    ```

13. Limpe a fila de e-mails do Postfix:

    ```bash
    postfix flush
    ```

14. Veja a fila de e-mails:

    ```bash
    mailq
    ```

15. Remova todos os e-mails da fila:

    ```bash
    postsuper -d ALL
    ```

16. Remova todos os e-mails adiados:

    ```bash
    postsuper -d ALL deferred
    ```

    