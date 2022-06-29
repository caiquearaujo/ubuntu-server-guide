# Configurações de Atualização Automática

1. Edite o arquivo de configuração do pacote Unattended Upgrades, `nano /etc/apt/apt.conf.d/50unattended-upgrades`, com o conteúdo abaixo:

   ```bash
   # Unattended-Upgrade::Allowed-Origins
   # Origens de repositórios permitidas para verificação de atualizações
   Unattended-Upgrade::Allowed-Origins {
       "${distro_id}:${distro_codename}";
       "${distro_id}:${distro_codename}-security";
       "${distro_id}ESMApps:${distro_codename}-apps-security";
       "${distro_id}ESM:${distro_codename}-infra-security";
       "${distro_id}ESM:${distro_codename}";
   };
   
   # Unattended-Upgrade::Mail
   # Envia um e-mail para o e-mail definido (assim que configurado o postfix)
   # sempre que houverem problemas ou atualizações de acordo com o tipo de relatório
   Unattended-Upgrade::Mail "<user>@<domínio>";
   
   # Unattended-Upgrade::MailReport
   # Tipo de relatório a ser recebido no e-mail
   # -> on-change = somente quando houverem mudanças
   # -> only-on-error = somente quando houverem erros
   # -> always = sempre que executar a atualização automática
   Unattended-Upgrade::MailReport "always";
   
   # Unattended-Upgrade::Remove-Unused-Dependencies 
   # Remove automaticamente as dependências ainda não utilizadas
   Unattended-Upgrade::Remove-Unused-Dependencies "true";
   
   # Unattended-Upgrade::Automatic-Reboot
   # Faz o reboot automático após uma atualização
   Unattended-Upgrade::Automatic-Reboot "true";
   
   # Unattended-Upgrade::Automatic-Reboot-WithUsers
   # Não faz o reboot se houver um usuário conectado
   Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
   
   # Unattended-Upgrade::Automatic-Reboot-Time
   # Define a hora para fazer o reboot automático
   Unattended-Upgrade::Automatic-Reboot-Time "02:00";
   
   # Unattended-Upgrade::SyslogEnable
   # Habilita o log de sistema
   Unattended-Upgrade::SyslogEnable "true";
   ```

   > Opcionalmente, você pode configurar outras regras no arquivo conforme sua necessidade.

2. Insira o conteúdo abaixo nos arquivos `/etc/apt/apt.conf.d/20auto-upgrades` e `/etc/apt/apt.conf.d/10periodic`:

   ```bash
   # Habilita a atualização automática da lista do repositório
   APT::Periodic::Update-Package-Lists "1";
   
   # Habilita o download automático dos pacotes para serem atualizados
   APT::Periodic::Download-Upgradeable-Packages "1";
   
   # Faz uma auto limpeza de pacotes inutilizádos a cada 3 dias
   APT::Periodic::AutocleanInterval "3";
   
   # Habilita o upgrade automático
   APT::Periodic::Unattended-Upgrade "1";
   ```

3. Após realizar as mudanças, execute o comando abaixo e verifique se não houveram erros:

   ```bash
   sudo unattended-upgrades --dry-run --debug
   ```

## Logs

Os logs de registro das atualizações automáticas estão disponíveis em `/var/log/unattended-upgrades` separados em três arquivos:

- `unattended-upgrades-dpkg.log`: Ações para updates, upgrades e remoção;
- `unattended-upgrades.log`: Listagem de pacotes e erros;
- `unattended-upgrades-shutdown.log`: Informações de reboots.