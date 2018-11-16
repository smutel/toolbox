#!/bin/bash

git_username="$1"
git_email="$2"

if [[ -z "${git_username}" ]]; then
  echo "GIT username not specified. (1st argument)"
  exit 1
fi

if [[ -z "${git_email}" ]]; then
  echo "GIT e-mail not specified. (2nd argument)"
  exit 1
fi

eval $(grep "^ID=" /etc/os-release)
if [[ "$ID" == "ubuntu" ]]; then
  sudo apt install build-essential cmake python3-dev
fi

echo "Load bashrc external ..."
if [[ ! -f ~/.bashrc_external ]]; then
  echo "Unable to load ~/.bashrc_external. Skipping."
else
  echo "Loading ~/.bashrc_external ..."
  source ~/.bashrc_external
fi

echo "Install ssh keys and config ..."
if [ ! -f ssh.tar.gz ]; then
  echo "Bundle ssh.tar.gz not found. Skipping"
else
  echo "Extracting ssh config ..."
  tar -zxf ssh.tar.gz
fi

echo "Restoring config ..."
find . -maxdepth 1 ! -path "." ! -path "./.git" -name ".*" -exec cp -rf {} ~ \;
if [[ ! -f ~/.bashrc.save ]]; then
  cp ~/.bashrc ~/.bashrc.save
fi
cat ~/.bashrc.save > ~/.bashrc
cat ~/.bashrc_custom >> ~/.bashrc

echo "Set user in gitconfig ..."
git config --global user.name ${git_username}
git config --global user.email ${git_email}

# Temporary vi alias
alias vi='vim'

echo "Install vundle plugin ..."
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
  echo "Clone vundle repository ..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else
  echo "Update personnal config repository ..."
  git -C ~/.vim/bundle/Vundle.vim pull
fi
vim -i NONE -c VundleUpdate -c quitall

echo "Installing additional stuf for youcompleteme ..."
cd ~/.vim/bundle/youcompleteme/
./install.py --clang-completer > /dev/null

echo "Cleanup ..."
rm -f ssh.tar.gz
