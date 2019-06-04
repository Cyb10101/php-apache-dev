#!/usr/bin/env bash

# Set Terminal title
function userTerminalTitle {
    echo -e '\033]2;'$1'\007'
}

# Set Terminal title - current folder
function userTerminalTitlePwd {
    echo -e '\033]2;'$(pwd)'\007'
}

# Set current user color
function userColorUser {
    if [[ $EUID -eq 0 ]]; then
        echo -e '\e[1;31m';
    else
        echo -e '\e[1;32m';
    fi
}

# @deprecated Check if ssh-agent process is not running and start it
function sshAgentRestart {
    if ! kill -0 ${SSH_AGENT_PID} 2> /dev/null; then
        eval `$(which ssh-agent) -s`;
    fi
}

# @deprecated Check if ssh-agent process is running and add ssh key
# Run: sshAgentAddKey 24h ~/.ssh/id_rsa
function sshAgentAddKey {
    if kill -0 ${SSH_AGENT_PID} 2> /dev/null; then
        if [ -f ${2} ]; then
            if ! ssh-add -l | grep -q `ssh-keygen -lf ${2}  | awk '{print $2}'`; then
                ssh-add -t ${1} ${2};
            fi
        fi
    fi
}

# @deprecated Run SSH Agent and add key 7 days
function sshAgentAddKeyOld {
    if [ -f ~/.ssh/id_rsa ] && [ -z "$SSH_AUTH_SOCK" ] ; then
        eval `ssh-agent -s`
        ssh-add -t 604800 ~/.ssh/id_rsa
    fi
}

# Style bash prompt
function stylePS1 {
    PS1='$(userTerminalTitlePwd)\[\e[0;36m\][$(userColorUser)\u\[\e[0;36m\]@\[\e[1;34m\]$DOCKER_COMPOSE_PROJECT\[\e[0;36m\]: \[\e[0m\]\w\[\e[0;36m\]]\[\e[0;36m\]> $(userColorUser)\n\$\[\e[0m\] ';
    if [ -f $(which git) ]; then
        PS1='$(userTerminalTitlePwd)\[\e[0;36m\][$(userColorUser)\u\[\e[0;36m\]@\[\e[1;34m\]$DOCKER_COMPOSE_PROJECT\[\e[0;36m\]: \[\e[0m\]\w\[\e[0;36m\]]\[\e[0;33m\]$(__git_ps1)\[\e[0;36m\]> $(userColorUser)\n\$\[\e[0m\] ';
    fi
}

# Style bash prompt
function bashCompletion {
  if [ -f $(which git) ]; then
      source /usr/share/bash-completion/completions/git
      source /etc/bash_completion.d/git-prompt
  fi
}

# Shortcuts in bash
function addAlias {
    # color grep
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    # ls
    alias l='ls -CF --color=auto'
    alias la='ls -A --color=auto'
    alias ll='ls -ahlF --color=auto'
    alias ls='ls --color=auto'

    # cd
    alias ..='cd ..'
    alias cd..='cd ..'

    # get current unixtime
    alias unixtime='date +"%s"'

    # show all open ports
    alias ports='netstat -tulanp'

    # less defaults
    alias less='less -FSRX'
}

function addDockerAlias {
    DOCKER_COMPOSE_PROJECT=$(sudo docker inspect ${HOSTNAME} | grep '"com.docker.compose.project":' | awk '{print $2}' | tr --delete '"' | tr --delete ',')
    NODE_CONTAINER=$(sudo docker ps -f "name=${DOCKER_COMPOSE_PROJECT}_node_1" --format {{.Names}})
    alias node='sudo docker exec -u $(id -u):$(id -g) -w $(pwd) -it ${NODE_CONTAINER} node'
    alias npm='sudo docker exec -u $(id -u):$(id -g) -w $(pwd) -it ${NODE_CONTAINER} npm'
    alias yarn='sudo docker exec -u $(id -u):$(id -g) -w $(pwd) -it ${NODE_CONTAINER} yarn'
    alias node_exec='sudo docker exec -u $(id -u):$(id -g) -w $(pwd) -it ${NODE_CONTAINER}'
    alias node_root_exec='sudo docker exec -w $(pwd) -it ${NODE_CONTAINER}'
}
