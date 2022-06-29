# Configuração do Banco de Dados

## MySQL

1. Instale o MySQL 8.0:

   ```bash
   sudo apt-get install mysql-server-8.0
   ```

2. Acesse o terminal `sudo mysql` e altere a senha do usuário `root` para uma senha segura 32 caracteres ou mais:

   ```mysql
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'mynewpassword';
   ```

3. Execute o assistente de instalação segura do MySQL:

   ```bash
   sudo mysql_secure_installation
   ```

   - Remova usuários anônimos;
   - Desabilite o login root remotamente;
   - Remova os bancos de dados para teste;
   - Recarregue os privilégios do MySQL.

4. Verifique o status do MySQL:

   ```bash
   sudo systemctl status mysql
   ```

   > Caso não esteja ativo por padrão, execute `sudo systemctl enable mysql`.

> ⚠️ Não libere a porta **3306** no Firewall, isso irá expor o MySQL na rede, se necessário só libere para os IPs autorizados. Para demais acesso, utilizaremos SSH Tunnel com redirecionamento de porta para uma transmissão de dados segura sobre o protocolo SSH.

## Usuários

Para criar novos usuários com MySQL, entre no terminal `sudo mysql` e execute:

```mysql
# Crie um novo "superusuário", para substituir o root
# user -> Nome do usuário
# host -> 127.0.0.1 para acesso via SSH Tunnel e localhost para acesso na própria máquina,
#		  informe outros IP se for o caso de um IP externo acessar o MySQL via porta 3306
# password -> Escolha uma senha segura
create user '<user>'@'<host>' identified by '<password>';
```

> ⚠️ Algumas aplicações podem ter incompatibilidade com o tipo de senha do MySQL 8.0, nestes casos basta trocar `identified by '<password>'` por `identified with mysql_native_password by '<password>'`.

A instrução `grant` no MySQL garante permissões de acesso de um usuário a bancos de dados, a tabelas e a opção de manipulação de permissões. Os privilégios disponíveis são:

- ALL PRIVILEGES garante todos os privilégios;
- CREATE permite apenas o comando `create`;
- DROP permite apenas o comando `drop`;
- DELETE permite apenas o comando `delete`;
- INSERT permite apenas o comando `insert`;
- UPDATE permite apenas o comando `update`;
- SELECT permite apenas o comando `select`;
- Acesse https://dev.mysql.com/doc/refman/8.0/en/grant.html para ver os tipos de privilégios.

A instrução para concessão de privilégios é:

```mysql
# db -> O nome do banco ou todos os bancos com *
# table -> O nome da tabela ou todas as tabelas com *
# '<user>'@'<host>' -> O usuário e o host liberado
# grant_option -> Utilize a expressão "with grant option" para permitir a manipulação de permissões
# @@ Associe todos os privilégios e a manipulação de permissões ao "superusuário"
grant <privileges> on <db>.<table> to '<user>'@'<host>' <grant_option>;
```

Após executar a função `grant` é necessário recarregar os privilégios:

```mysql
flush privileges;
```

Os privilégios podem ser revogados com o comando:

```mysql
revoke <privileges> on <db>.<table> from '<user>'@'<host>';
```

Um usuário pode ser removido com o comando:

```mysql
drop user '<user>'@'<host>'; 
```

Renomeia um usuário:

```bash
rename user 'root'@'localhost' to '<new_user>'@'localhost';
```

O MySQL permite gerenciar as contas de muitas maneiras, as principais instruções são:

- ALTER USER -> Altera propriedades do usuário;
- CREATE ROLE -> Cria um cargo para o usuário;
- CREATE USER -> Cria um usuário;
- DROP ROLE -> Remove um cargo criado;
- DROP USER -> Remove um usuário criado;
- GRANT -> Garante permissões ao usuário;
- RENAME USER -> Renomeia algum usuário;
- REVOKE -> Remove permissões do usuário;
- SET DEFAULT ROLE -> Define um cargo padrão;
- SET PASSWORD -> Define uma senha para o usuário;
- SET ROLE -> Define um cargo para o usuário.

>  Todos esses comandos fazem parte da linguagem SQL e podem ser explorados em https://dev.mysql.com/doc/refman/8.0/en/account-management-statements.html

### Cargos

Um recurso interessante do MySQL remete aos cargos em https://www.mysqltutorial.org/mysql-roles/#:~:text=Introduction%20to%20MySQL%20roles,a%20new%20object%20called%20role. Os cargos são facilitadores, ao invés de autorizar permissões individualmente aos usuários. Pode-se criar um cargo com permissões compatíveis e associar aos usuários. Por exemplo: você pode criar os cargos: administrator, developer e criar as regras padrões.

No sentido mais básico, você pode criar os usuários e entender quais permissões são necessárias aqueles usuários. 

> Evite utilizar ALL PRIVILEGES para usuários comuns ou do sistema, como um usuário Wordpress, assim você evita problemas maiores.

### SSH Tunnel

1. Associe um usuário que irá se conectar ao MySQL via SSH ao grupo `sqlvps`:

   ```bash
   sudo usermod -aG sqlvps <user>
   ```

2. Edite as configurações do SSH e adicione ao final do arquivo:

   ```bash
   Match Group sqlvps
   	PermitTunnel yes
       # Desabilita o redirecionamento de porta
       AllowTcpForwarding yes
           # Permite o Tunnel apenas para a porta 3306
           PermitOpen 127.0.0.1:3306
   ```

Agora o usuário já poderá fazer a conexão com o MySQL via SSH Tunnel em qualquer cliente MySQL.