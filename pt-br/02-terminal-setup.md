# Configuração do Terminal

## Estilo padrão do Prompt

Edite o estilo do **prompt** para exibir informações mais claras sobre o comando atual em execução. Ele é gerenciado através da variável de ambiente **PS1**. A edição deve ser feita de duas formas:

1. Crie um novo arquivo de configuração em `/etc/profile.d` com o nome `02-ps1-style.sh` e defina o conteúdo padrão do **prompt**;

2. Altere os arquivos `~/.bashrc` e `~/.profile` individualmente por usuário.

	> Neste caso, você pode optar por alterar as permissões dos arquivos para `root:root`, dessa forma, o usuário não conseguirá alterar as modificações que você fez.

> Em http://bashrcgenerator.com/ você pode personalizar a instrução PS1 da forma como você deseja exibí-la.

Para padronização, utilizamos o valor abaixo:

```bash
PS1='\[$(tput bold)\]\[\033[38;5;13m\]\A\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \u@\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;9m\]\h\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;11m\][\w]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;165m\]\\$\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]'
```

O resultado acima irá produzir: `HH:MM user@hostname:[folder] #`.

## ZSH

O **ZSH** é um interpretador de comando para *shell scripting* cuja finalidade é facilitar o uso da ferramenta em si. Ele é essencial para aumentar a produtividade de controle do terminal.

1. Instale o ZSH e as demais bibliotecas essenciais:

    ```bash
    sudo apt-get install zsh curl git
    ```

2. Instale framework de gerenciamento do ZSH:

    ```bash
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```

3. Instale o tema **PowerLevel10K** para o ZSH:

    ```bash
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    ```

4. Edite o arquivo de configuração do ZSH `nano .zshrc` e edite a seguinte variável:

    ```bash
    ZSH_THEME="powerlevel10k/powerlevel10k"
    ```

5. Execute o assistente de configuração `p10k configure` para configurar o tema e, depois, edite o arquivo de configuração do tema `nano .p10k.zsh` com as seguintes variáveis:

    ```bash
    # Cor do primeiro plano
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=011
    
    # Template para usuário root: root@hostname.
    typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE="%F{015}%n%f%F{161}@%m%f"
    # Template para o usuário padrão: user@hostname.
    typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE="%F{015}%n%f%F{161}@%m%f"
    # Não exibe o contexto a menos que esteja no usuário root ou sudo
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=
    
    # Altere a cor da hora
    typeset -g POWERLEVEL9K_TIME_FOREGROUND=200
    
    # Segmentos do prompt à esquerda
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    	# =========================[ Line #1 ]=========================
        context                   # user@host
        dir                       # current directory
        vcs                       # git status
        command_execution_time    # previous command duration
        # =========================[ Line #2 ]=========================
        newline                   # \n
        virtualenv                # python virtual environment
        prompt_char               # prompt symbol
    )
    
    # Segmentos do prompt à direita
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        # =========================[ Line #1 ]=========================
        # command_execution_time  # previous command duration
        # virtualenv              # python virtual environment
        # context                 # user@host
        time                      # current time
        # =========================[ Line #2 ]=========================
        newline                   # \n
    )
    ```

  > As cores no terminal são definidas em três dígitos numéricos, acima as cores foram pré-definidas com base na nossa padronização. `F{XXX}` indica cor do primeiro plano *(foreground)* e `B{XXX}` cor do último plano *(background)*.
  >
  > Mas, você pode alterar as cores a qualquer momento conforme suas preferências. Para isso, execute no terminal o comando `for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done`, este comando exibirá todas as cores e códigos para cada uma delas. Então altere os dígitos de cores para os desejados.

### Plugins

O ZSH conta com diversos plugins para gerenciar melhor o terminal, alguns deles já vem pré-instalados e outros podem ser instalados e configurações. Abaixo, toda a configuração para os plugins ideais:

#### Syntax Highlight

1. Instale o plugin:

	```bash
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
	```

2. Habilite o plugin no arquivo de inicialização do ZSH `nano ~/.bashrc`:

	```bash
	plugins=(git colored-man-pages zsh-syntax-highlighting)
	```

#### Auto Suggestions

1. Instale o plugin:

	```bash
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
	```

2. Habilite o plugin no arquivo de inicialização do ZSH `nano ~/.bashrc`:

	```bash
	plugins=(git colored-man-pages zsh-syntax-highlighting zsh-autosuggestions)
	
	# Insira a variável para manipular a cor da auto sugestão
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
	```
	

---

Depois de configurar todos os plugins, execute `source $HOME/.zshrc` para recarregar o ZSH e aplicar as mudanças sem reiniciar o terminal.

