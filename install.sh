#!/bin/bash

# variaveis de ambiente
DEBUG_LOGS=$HOME/.appDebugLogs/debug_logs_tracking
ANDROID_SCRIPT=""
IOS_SCRIPT=""
ADB_URL_LINUX=https://dl.google.com/android/repository/platform-tools-latest-linux.zip
ADB_URL_MAC=https://dl.google.com/android/repository/platform-tools-latest-darwin.zip
OS_INFO=`uname`


function get_os_info {
    if [[ $OS_INFO == "Linux" ]]; then
        echo "Você é um usuário do Linux. Demais!"
    elif [[ $OS_INFO == "Darwin" ]]; then
        echo "Você é um usuário do Mac. Bom estilo!"
    else
        [[ $OS_INFO == "WindowsNT" ]]
        echo "Você é um usuário do Windows. Ferrou!"
    fi
}


function criar_appDebugLogs {
    echo -e "=> Começando...\n"
    if [[ -d $DEBUG_LOGS ]]; then
        echo "O diretório .appDebugLogs existe!"
    else
        echo "O diretório .appDebugLogs não existe. Criando diretórios:"
        mkdir -v -p $DEBUG_LOGS
    fi
}


function baixar_repo {
    echo -e "\n=> Baixando repositório:"
    if git --version; then
        git clone https://github.com/JanioPG/Debug-Logs-Tracking.git $DEBUG_LOGS

        if [[ $? -eq 0 ]]; then
            echo "Feito: repositório baixado!"
            add_alias
        else
            echo "Erro ao baixar o repositório. Veja o erro e após corrigir, se necessário, execute novamente o script."
            echo "Nota: Se o diretório(fica na sua home) já existe e não está vazio, caso queira baixar novamente o repositório, considere limpar."
        fi
    else
        echo "Git não está instalado."
        echo " Instale com apt para Linux (debian/ubuntu): 'sudo apt install git'."
        echo " Ou com o homebrew para Mac: 'brew install git'."
        echo " NOTA: Após instalar, adicione seu nome com 'git config --global user.name 'seunome'."
        echo "       Adicione seu e-mail com 'git config --global user.email 'example@domain.com'."
    fi
}


function add_alias {
    echo -e "\n=> Adicionando alias para os scripts."
    ANDROID_SCRIPT=`find $HOME/.appDebugLogs -iname 'android*logs.py' -print`
    IOS_SCRIPT=`find $HOME/.appDebugLogs -iname 'ios*logs.py' -print`

    # zsh
    if grep 'alias\ tracking_android' ~/.zshrc; then
        echo "alias tracking_android existe no arquivo .zshrc."
    else
        echo "alias tracking_android='python3 $ANDROID_SCRIPT'" >> ~/.zshrc
    fi

    if grep 'alias\ tracking_ios' ~/.zshrc; then
        echo "alias tracking_ios existe no arquivo .zshrc."
    else
        echo "alias tracking_ios='python3 $IOS_SCRIPT'" >> ~/.zshrc
    fi
    echo "  Concluído para zsh."


    # bash
    if grep 'alias\ tracking_android' ~/.bashrc; then
        echo "alias tracking_android existe no arquivo .bashrc."
    else
        echo "alias tracking_android='python3 $ANDROID_SCRIPT'" >> ~/.bashrc
    fi

    if grep 'alias\ tracking_ios' ~/.bashrc; then
        echo "alias tracking_ios existe no arquivo .bashrc."
    else
        echo "alias tracking_ios='python3 $IOS_SCRIPT'" >> ~/.bashrc
    fi
    echo "  Concluído para bash."

    install_adb
}


function add_adb_to_path {
    echo -e "\n=> Adicionando 'adb' à variável path:"

    if ! grep 'export\ PATH.*platform-tools' ~/.zshrc; then
        echo "Adicionando adb na variável path" >> ~/.zshrc
        echo "export PATH=$PATH:$HOME/.appDebugLogs/platform-tools" >> ~/.zshrc
    fi
    echo "  Concluído para zsh."

    if ! grep 'export\ PATH.*platform-tools' ~/.bashrc; then
        echo "Adicionando adb na variável path" >> ~/.bashrc
        echo "export PATH=$PATH:$HOME/.appDebugLogs/platform-tools" >> ~/.bashrc
    fi
    echo " Concluído para bash."
}


function download_adb {
    get_os_info
    if [[ $OS_INFO == "Linux" ]]; then
        curl $ADB_URL_LINUX -# -L --create-dirs -o $HOME/.appDebugLogs/platform-tools.zip -C -
    elif [[ $OS_INFO == "Darwin" ]]; then
        curl $ADB_URL_MAC -# -L --create-dirs -o $HOME/.appDebugLogs/platform-tools.zip -C -
    else
        echo "Você não é usuário Linux e nem Mac. Mas baixe o adb para seu sistema operacional em 'https://developer.android.com/studio/releases/platform-tools'."
    fi

    if [[ $? -eq 0 ]]; then
        echo "adb baixado com sucesso. Descompactando:"
        cd $HOME/.appDebugLogs && unzip platform-tools.zip

        add_adb_to_path

    else
        echo "Erro ao baixar o adb. Veja o erro e tente executar novamente o script."
        echo "Se for o erro '92', talvez seja porque você já tem o arquivo do adb baixado na pasta .appDebugLogs."
    fi
}


function install_adb {
    echo -e "\n=> Verificando se o 'adb' está instalado:"
    if ! adb --version; then
        echo "O 'adb' não foi encontrado."
        echo "Nota: Se você instalou o Android Studio, talvez precise adicionar o adb à variável path ou adicionar um alias."

        if [[ $OS_INFO == "Darwin" ]]; then
            if find ~/Library/Android/sdk/platform-tools -iname adb -print; then
                echo "Apesar disso, encontrei o adb em ~/Library/Android/sdk/platform-tools. Adicione-o à variável path para usar."
                echo "  Em seu arquivo .zshrc (ou .bashrc) na home, adicione a linha:"
                echo "    export PATH=<Variavel_PATH>:<Variavel_HOME>/Library/Android/sdk/platform-tools"
            fi
        elif [[ $OS_INFO == "Linux" ]]; then
            if ls `find ~/Android -type d -iname platform-tools -print` | grep adb; then
                echo "Apesar disso, encontrei o adb em ~/Android/platform-tools. Adicione-o à variável path para usar."
                echo "  Em seu arquivo .zshrc (ou .bashrc) na home, adicione a linha."
                echo "    export PATH=<Variavel_PATH:<Variavel_HOME>/Android/platform-tools"
            fi
        fi


        while true; do
        read -n1 -p "Deseja instalar o adb? [Y/n]: " resposta
            case $resposta in
                Y | y) echo
                    echo "Você escolheu instalar."
                    download_adb
                    break;;
                N | n) echo
                    break;;
                *) echo
                    echo "Opção inválida. Digite somente y ou n.";;
            esac
        done
    fi

    mensagem_concluido
}


function mensagem_concluido {
    echo -e "\n=> Concluído!"
    echo "Reincie o terminal fechando e abrindo novamente para que as configurações do shell sejam recarregadas."
    echo "Recarregadas as configurações, execute no seu terminal 'tracking_android' para ver os eventos de Android ou 'tracking_ios' para ver os eventos de iOS."
}

criar_appDebugLogs
baixar_repo