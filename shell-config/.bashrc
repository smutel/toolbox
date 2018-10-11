# .bashrc

####################
#    VARIABLES     #
####################

SSH_ENV="$HOME/.ssh/environment"

####################
#     FUNCTIONS    #
####################

function run_ssh_env {
  . "${SSH_ENV}" > /dev/null
}

function start_ssh_agent {
  echo "Initializing new SSH agent..."
  ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo "succeeded"
  chmod 600 "${SSH_ENV}"

  run_ssh_env
  ssh-add ~/.ssh/id_dsa
  ssh-add ~/.ssh/id_rsa
}

function parse_git_branch {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

####################
#       MAIN       #
####################

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source external .bashrc
if [ -f ~/.bashrc_external ]; then
  . ~/.bashrc_external
fi

# Source bash completion
for i in ~/.bash_completion.d/*; do
  . $i
done

# Start SSH agent
if [ -f "${SSH_ENV}" ]; then
  run_ssh_env
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_ssh_agent
  }
else
  start_ssh_agent
fi

# Create some alias
alias vi='vim'

# Change shell prompt
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# Change color of current terminal
export TERM=xterm-256color

# Disable the XON/XOFF feature
stty -ixon
