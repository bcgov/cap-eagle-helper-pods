PACKAGE_MANAGER=""

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    PACKAGE_MANAGER="brew";
elif [[ "$OSTYPE" == "cygwin"* || "$OSTYPE" == "msys"* || "$OSTYPE" == "win"* ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    PACKAGE_MANAGER="choco";
elif [[ "$OSTYPE" == "linux"* ]]; then
    if grep -qi Microsoft /proc/sys/kernel/osrelease 2> /dev/null; then
        # Win10 bash
        PACKAGE_MANAGER="choco";
    else
        # Linux
        DISTRO=$(lsb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 || uname -om);
        if [[ "$DISTRO" == *"hat"* || "$DISTRO" == *"centos"* ]]; then
            PACKAGE_MANAGER="yum";
        elif [[ "$OSTYPE" == *"debian"* || "$OSTYPE" == *"ubuntu"* ]]; then
            PACKAGE_MANAGER="apt";
        fi
    fi
elif [[ "$OSTYPE" == "bsd"* || "$OSTYPE" == "solaris"* ]]; then
    # not supported
    echo -e \\n"OS not supported. Supported OS:\\nMac OSX\\nWindows\\nDebian\\nFedora\\n"\\n
    exit 1
else
    echo -e \\n"OS not detected. Supported OS:\\nMac OSX\\nWindows\\nDebian\\nFedora\\n"\\n
    exit 1
fi


if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    which -s brew;
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
    fi
    brew update;
    brew install terraform azure-cli
elif [[ "$PACKAGE_MANAGER" == "choco" ]]; then
    sudo PowerShell -NoProfile -ExecutionPolicy remotesigned -Command ". 'install_choco.ps1;"
    choco upgrade chocolatey;
    choco install terraform azure-cli -y;
elif [[ "$PACKAGE_MANAGER" == "yum" ]]; then
    curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
    unzip terraform.zip
    mv terraform ~
    rm terraform.zip
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc;
    sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo';
    yum check-update;
    sudo yum -y install azure-cli;
elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
    curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
    unzip terraform.zip
    mv terraform ~
    rm terraform.zip
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else
    echo -e \\n"Packages not installed.\\n"\\n
    exit 1
fi

echo "Finished installing developer prerequisites"