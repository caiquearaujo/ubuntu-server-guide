# Primeiras Atualizações

Ao iniciar o sistema pela primeira vez, é ideal realizar uma atualização completa de rotina. Para isso, basta executar o seguinte comando com o usuário `root`:

```bash
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
```

## Kernel

1. Verifique a versão atual do kernel, a arquitetura e a versão do sistema:

   ```bash
   uname -r
   < 5.11.0-38-generic
   
   dpkg --print-architecture
   < amd64
   
   lsb_release -a
   < No LSB modules are available.
   < Distributor ID: Ubuntu
   < Description:    Ubuntu 20.04.3 LTS
   < Release:        20.04
   < Codename:       focal
   ```

2. Atualize para a última versão mais estável do kernel, conforme a versão do seu Ubuntu disponível em https://ubuntu.com/kernel/lifecycle, execute o comando na versão para Servidor:

   ```bash
   sudo apt-get install --install-recommends linux-generic-hwe-20.04
   ```

3. Reinicie a máquina:

   ```bash
   # Reinicie
   reboot
   ```

4. Verifique o kernel atualizado com `uname -r`.