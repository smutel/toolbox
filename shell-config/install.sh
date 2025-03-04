#!/bin/bash

git_username="$1"
git_email="$2"

GO_VERSION="1.23.1"
KUBECTX_VERSION="0.9.5"

if [[ -z "${git_username}" ]]; then
  echo "GIT username not specified. (1st argument)"
  exit 1
fi

if [[ -z "${git_email}" ]]; then
  echo "GIT e-mail not specified. (2nd argument)"
  exit 1
fi

eval "$(grep "^ID=" /etc/os-release)"
if [[ "$ID" == "ubuntu" ]]; then
  echo "Install some packages ..."

  # Docker repository
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") \
    stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Keepassrc repository
  sudo add-apt-repository -y ppa:phoerious/keepassxc > /dev/null

  # Granted repository
  wget -q -O- https://apt.releases.commonfate.io/gpg | sudo gpg --batch --yes \
    --dearmor -o /usr/share/keyrings/common-fate-linux.gpg
  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/common-fate-linux.gpg] \
    https://apt.releases.commonfate.io stable main" | sudo tee \
    /etc/apt/sources.list.d/common-fate.list > /dev/null

  sudo apt update > /dev/null 2>&1
  sudo apt install -y build-essential cmake python3-dev vim \
    tmux git keepassxc gnome-tweaks gnome-shell-extensions libfuse2 \
    gnome-shell-extension-manager gimp ttf-mscorefonts-installer \
    filezilla meld audacity shellcheck jq imagemagick build-essential \
    makepasswd direnv granted curl cmake docker-ce docker-ce-cli \
    containerd.io docker-buildx-plugin docker-compose-plugin> /dev/null 2>&1

  sudo usermod -a -G docker samuel
fi

echo "Load bashrc external ..."
if [[ ! -f ~/.bashrc_external ]]; then
  echo "Unable to load ~/.bashrc_external. Skipping."
else
  echo "Loading ~/.bashrc_external ..."
  # shellcheck source=/dev/null
  source ~/.bashrc_external
fi

echo "Restoring config ..."
find . -maxdepth 1 ! -path "." ! -path "./.git" -name ".*" -exec cp -rf {} ~ \;
if [[ ! -f ~/.bashrc.save ]]; then
  cp ~/.bashrc ~/.bashrc.save
fi
cat ~/.bashrc.save > ~/.bashrc
cat ~/.bashrc_custom >> ~/.bashrc

echo "Set user in gitconfig ..."
git config --global user.name "${git_username}"
git config --global user.email "${git_email}"

echo "Install go ..."
if [ ! -d /opt/go${GO_VERSION} ]; then
  curl -Ls https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz
  rm -rf /tmp/go
  tar -zxf /tmp/go${GO_VERSION}.linux-amd64.tar.gz -C /tmp
  sudo mv /tmp/go /opt/go${GO_VERSION}
  sudo ln -sf /opt/go${GO_VERSION} /opt/go
fi
export GO_PATH=/opt/go
export PATH="${GO_PATH}/bin:$PATH"

echo "Install tpm ..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
  mkdir -p ~/.tmux/plugins/tpm
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --quiet
fi

echo "Install spell files ..."
mkdir -p ~/.vim/spell
curl -Ls http://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.spl \
  -o ~/.vim/spell/fr.utf-8.spl
curl -Ls http://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.sug \
  -o ~/.vim/spell/fr.utf-8.sug

# Temporary vi alias
alias vi='vim'

echo "Install vundle plugin ..."
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
  echo "Clone vundle repository ..."
  git clone https://github.com/VundleVim/Vundle.vim.git \
    ~/.vim/bundle/Vundle.vim
else
  echo "Update personnal config repository ..."
  git -C ~/.vim/bundle/Vundle.vim pull
fi
vim -i NONE -c VundleUpdate -c quitall

echo "Installing additional stuf for youcompleteme ..."
cd ~/.vim/bundle/youcompleteme/ && ./install.py --clang-completer \
  --go-completer > /dev/null
vim -i NONE -c GoInstallBinaries -c quitall

echo "Create ~/bin directory ..."
mkdir -p ~/bin

echo "Download kubernetes tools ..."
mkdir -p ~/.bash_completion.d
curl -sL https://dl.k8s.io/release/"$(curl -Ls \
  https://dl.k8s.io/release/stable.txt)"/bin/linux/amd64/kubectl \
  -o ~/bin/kubectl
chmod 755 ~/bin/kubectl
"$HOME"/bin/kubectl completion bash | sudo tee ~/.bash_completion.d/kubectl > /dev/null

GH_URL="https://github.com/ahmetb/kubectx/releases/download/"

for p in kubectx kubens; do
  curl -sL "${GH_URL}/v${KUBECTX_VERSION}/${p}_v${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
    -o "/tmp/$p.tar.gz"
  tar -zxf "/tmp/$p.tar.gz" -C /tmp
  cp /tmp/$p ~/bin
  chmod 755 ~/bin/$p
done

echo "Load tmux plugins ..."
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins
