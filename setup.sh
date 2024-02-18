#!/bin/bash
git_name="Johannes Pertl"
git_email=$1

if [ -z "$git_email" ]; then
  echo "Usage: $0 <git_email>"
  exit 1
fi

cmd_missing() {
 ! command -v "$1" &> /dev/null
}

setup_git() {
  if cmd_missing git; then
    sudo apt install git -y &
  fi
  git config --global core.editor "vim"
  git config --global user.name "${git_name}"
  git config --global user.email "${git_email}"
  git config --global credential.helper store
  # always use ssh
  git config --global url."git@github.com:".insteadOf "https://github.com/"

}

setup_fish() {
  if cmd_missing fish; then
    sudo apt-add-repository ppa:fish-shell/release-3 -y
    sudo apt update
    sudo apt install fish -y
  fi
  sudo chsh -s "$(which fish)" "$USER"

  # TODO: Replace with tide?
  if cmd_missing omf; then
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install >install &&
      chmod +x install
    ./install --noninteractive
    rm install
  fi
  fish -c "omf install bobthefish"
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
  fish -c "fisher install jethrokuan/z"

}

setup_nvm() {
  if cmd_missing nvm; then
    fish -c "fisher install jorgebucaran/nvm.fish"
    fish -c "nvm install latest"
    fish -c "set --universal nvm_default_version latest"
  fi
}

setup_homebrew() {
  if cmd_missing brew; then
    echo -ne '\n' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fish -c "fish_add_path /home/linuxbrew/.linuxbrew/bin"
  fi
}

setup_dependencies() {
  if cmd_missing snap; then
    sudo rm /etc/apt/preferences.d/nosnap.pref
    sudo apt install -y snapd
  fi
  sudo apt update -y && sudo apt upgrade -y &&
    sudo apt install curl -y &&
    setup_git
  sudo apt install -y python3-dev python3-pip python3-setuptools
  setup_fish
  setup_nvm
  setup_homebrew
  setup_fonts
}

setup_chrome() {
  if cmd_missing google-chrome; then
    sudo apt install fonts-liberation &&
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
      sudo apt install -y ./google-chrome-stable_current_amd64.deb &&
      rm ./google-chrome-stable_current_amd64.deb
  fi
}

setup_dotfiles() {
  cp -r .config ~
  swaymsg reload
}

setup_httpie(){
  if cmd_missing http; then
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list
    sudo apt update
    sudo apt install httpie
  fi
}


setup_tools() {
  sudo apt install pipx -y && pipx install shell-gpt && pipx ensurepath
  #npm install -g tldr

  sudo apt install -y jq at bat imwheel adb
  sudo mv "$(which batcat)" /usr/bin/bat
  sudo cp bin/mousewheel.sh /usr/bin/scroll

  setup_httpie

  if cmd_missing fuck; then
    pipx install thefuck && pipx ensurepath && 
	    sudo mv ~/.local/bin/thefuck /usr/bin/thefuck
	    sudo mv ~/.local/bin/fuck /usr/bin/fuck
  fi
  # TODO: Ultrawide

  if cmd_missing bun; then
    curl -fsSL https://bun.sh/install | bash
  fi
}

setup_docker() {
  if cmd_missing docker; then
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null sudo apt-get update
  
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
  fi
}

setup_vscode() {
  if cmd_missing code; then
    wget "https://go.microsoft.com/fwlink/?LinkID=760868" -O /tmp/vscode.deb &&
    sudo apt install -y /tmp/vscode.deb
  fi
}

setup_fonts() {
  # Nerdfonts (required for nvchad) 
  mkdir -p ~/.local/share/fonts
  cd ~/.local/share/fonts
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
  unzip JetBrainsMono.zip
  rm JetBrainsMono.zip
}

setup_neovim() {
  brew install neovim
  # Nvchad 
  sudo apt install -y ripgrep
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
  # TODO: Install copilot
}

setup_dev_stuff() {
  # Java 18
  # sudo apt install openjdk-18-jdk -y &&
	  fish -c "set -Ux JAVA_HOME /usr/lib/jvm/java-18-openjdk-amd64/"
  # Firebase
  sudo curl -sL https://firebase.tools | bash &&
	  dart pub global activate flutterfire_cli &&
	  fish -c "fish_add_path $HOME/.pub-cache/bin"
  
  setup_vscode
  setup_neovim
}

setup_grub_customizer() {
  if cmd_missing grub-customizer; then
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
    sudo apt-get update
    sudo apt-get install grub-customizer -y
  fi
}

setup_discord() {
  if cmd_missing discord; then
    wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord.deb
	  sudo apt install -y /tmp/discord.deb
  fi
}


setup_user_apps() {
  setup_discord
  
  # Signal
  if cmd_missing signal-desktop; then
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
    cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null &&
	  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
    sudo tee -a /etc/apt/sources.list.d/signal-xenial.list &&
    sudo apt update && sudo apt install signal-desktop &&
    rm signal-desktop-keyring.gpg
  fi
}

setup_laptop() {
  sudo sed -i -e 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf	
  sudo sed -i -e 's/#HandlePowerKey=poweroff/HandlePowerKey=suspend/g' /etc/systemd/logind.conf 
}

setup_jenv(){
  if cmd_missing jenv; then
    brew install jenv &&
    fish -c "fish_add_path $HOME/.jenv/bin"
  fi
}

setup_dependencies
setup_chrome
setup_dotfiles
setup_tools
setup_dev_stuff
setup_grub_customizer
setup_user_apps
setup_laptop
setup_docker
setup_jenv
