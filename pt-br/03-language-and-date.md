# Configuração de Localização

## Idioma

1. Execute o comando `sudo locale -a` e verifique se já existe a localização `pt_BR` e `pt_BR.utf8`;

2. Caso esteja ausente, execute os seguintes procedimentos:

   ```bash
   # Instale o language-pack em português
   sudo apt-get install language-pack-pt
   
   # Gere os arquivos de localização
   sudo locale-gen pt_BR pt_BR.UTF-8
   
   # Atualize as localizações
   sudo update-locale
   
   # Reconfigure as localizações ativas
   # > Selecione pt_BR.UTF-8 como padrão
   sudo dpkg-reconfigure locales
   ```

3. Após a configuração, se tiver problemas com o layout do teclado, execute `sudo dpkg-reconfigure keyboard-configuration` e selecione o teclado `ABNT2`.

## Data & Hora

1. Instale o protocolo de rede para sincronização de data e hora:

   ```bash
   sudo apt-get install ntp ntpdate
   ```

2. Acesse o website https://www.pool.ntp.org/zone/@ e localize a zona mais próxima da localização do seu servidor;

3. Edite o arquivo `nano /etc/ntp.conf` e insira os servidores localizados acima, logo abaixo da linha indicada pelo comentário:

   ```bash
   # Specify one or more NTP servers.
   server 0.us.pool.ntp.org
   server 1.us.pool.ntp.org
   server 2.us.pool.ntp.org
   server 3.us.pool.ntp.org
   ```

   > Se o servidor estiver no Brasil, troque `us` por `br`.

4. Reinicie o serviço NTP e verifique o status:

   ```bash
   sudo systemctl restart ntp
   sudo systemctl status ntp
   ```

   > O serviço deve estar habilitado e em operação.

5. Altere o fuso horário da máquina para o fuso horário de trabalho, isto é onde “virtualmente” a máquina vai realizar as suas operações:

   ```bash
   sudo timedatectl set-timezone America/Sao_Paulo
   ```

6. Certifique-se que as alterações foram aplicadas:

   ```bash
   sudo timedatectl status
   ```

   