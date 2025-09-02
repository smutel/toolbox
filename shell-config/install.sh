#!/bin/bash

GIT_USERNAME="smutel"
GIT_EMAIL="12967891+smutel@users.noreply.github.com"

MISE_TOOLS="pipx python@3.13 go goreleaser terraform usage shellcheck direnv \
  kubectl kubectx kubens k9s yq yamllint ripgrep ast-grep lua prettier \
  packer pipx:sqlfluff fd fzf lazygit tree-sitter markdownlint-cli2 \
  npm:markdown-toc jq"

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
    stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  # Keepassrc repository
  sudo add-apt-repository -y ppa:phoerious/keepassxc >/dev/null

  # Granted repository
  wget -q -O- https://apt.releases.commonfate.io/gpg | sudo gpg --batch --yes \
    --dearmor -o /usr/share/keyrings/common-fate-linux.gpg
  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/common-fate-linux.gpg] \
    https://apt.releases.commonfate.io stable main" | sudo tee \
    /etc/apt/sources.list.d/common-fate.list >/dev/null

  sudo install -dm 755 /etc/apt/keyrings
  wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee \
    /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] \
    https://mise.jdx.dev/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/mise.list

  sudo apt update >/dev/null 2>&1
  sudo apt install -y build-essential cmake python3-dev \
    git keepassxc gnome-tweaks gnome-shell-extensions libfuse2 \
    gnome-shell-extension-manager gimp ttf-mscorefonts-installer \
    filezilla meld audacity imagemagick build-essential \
    makepasswd granted curl cmake docker-ce docker-ce-cli \
    containerd.io docker-buildx-plugin docker-compose-plugin mise \
    wl-clipboard >/dev/null 2>&1

  sudo usermod -a -G docker samuel
  sudo snap install nvim --classic
fi

echo "Install mise tools ..."
for tool in $MISE_TOOLS; do
  mise use -g "$tool"
done

echo "Install kitty ..."
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
echo 'kitty.desktop' >~/.config/xdg-terminals.list

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
cat ~/.bashrc.save >~/.bashrc
cat ~/.bashrc_custom >>~/.bashrc

echo "Set user in gitconfig ..."
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

echo "Install completion for some tools ..."
kubectl completion bash | sudo tee ~/.bash_completion.d/kubectl >/dev/null
