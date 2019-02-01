# -*- Mode: shell-script -*-
THIS=$(readlink -f ${BASH_SOURCE})
THIS_DIR=$(dirname ${THIS})


# --- utility functions ----------------------------------------------

# determine if $dir already exists in PATH-like variable $var
function in_path_var()
{
    var="$1"
    dir="$2"

    awk -F: '{ for (i=1; i<=NF; i++) print $i }' <<<"$var" | grep -q "^${dir}\$"
}

# add a directory to a PATH-like var if it's not already there
# if location is "head", add it to the head of the list
# if force is "force", add it even if it already exists in the list
function add_to_pathish()
{
    local varname="$1"
    local dir="$2"
    local location="$3"
    local force="$4"

    local value=$(eval "echo \$${varname}")

    if [ "$force" = "force" ] || ! in_path_var "$value" "$dir"; then
        if [ -z "$value" ]; then
            # var was empty
            eval "export $varname=\"$dir\""
        elif [ "$location" = "head" ]; then
            eval "export $varname=\"$dir:$value\""
        else
            eval "export $varname=\"$value:$dir\""
        fi
    fi
}

# add a directory to our PATH if it's not already there
function add_to_path()
{
    local dir="$1"
    local location="$2"
    local force="$3"

    add_to_pathish PATH "$dir" "$location" "$force"
}

# add_to_path a directory if it exists
function add_to_path_if()
{
    local dir="$1"
    local location="$2"
    local force="$3"

    [ -d "$dir" ] && add_to_path "$dir" "$location" "$force"
}

# Source a file if it exists.
#
# Return 0 if the file exists, 1 otherwise.
function source_if()
{
    local file="$1"

    if [ -e "$file" ]; then
        source "$file"
        return 0
    fi
    return 1
}

# Iterate over arguments and source the first file that exists.
#
# Return 0 if any of the files was found, 1 if no files were found.
function source_first()
{
    for file in "$@"; do
        source_if "$file" && return 0
    done

    return 1
}

# --- local pre options ----------------------------------------------
source_if "$THIS_DIR/local.first"

# --- configuration variables ----------------------------------------
add_to_path_if "$HOME/bin" head force
add_to_path_if "$HOME/.local/bin"

# where I keep source code for things
: ${SRC_DIR:="$HOME/src"}

add_to_path_if "$SRC_DIR/gpg-stupid"

# --- shell options --------------------------------------------------
shopt -s checkwinsize
shopt -s histappend
shopt -s cmdhist

# make sure color escape codes work in less
if ! grep -qi "r" <<<"$LESS"; then
    export LESS="$LESS -r"
fi

source "$THIS_DIR/feature-switch"
export PS1="\h:\W \u \$(set_env_ps1)\$ "
export HISTCONTROL='ignoreboth'
# ls color output
export CLICOLOR=1

# --- python virtualenvs ---------------------------------------------
export WORKON_HOME="$HOME/virtualenvs"
source_first /usr/local/bin/virtualenvwrapper.sh /etc/bash_completion.d/virtualenvwrapper

# -- pyenv -----------------------------------------------------------
add_to_path_if "$HOME/.pyenv/bin"
if which pyenv > /dev/null; then
    eval "$(pyenv init -)";
    export PYENV_ROOT="$HOME/.pyenv"
    add_to_path "$PYENV_ROOT/bin" head

    if which pyenv-virtualenv-init > /dev/null; then
        eval "$(pyenv virtualenv-init -)";
    fi
fi

# --- ruby rbenv -----------------------------------------------------
add_to_path_if "$HOME/.rbenv/bin" head
if which rbenv > /dev/null; then
    # I'll manage my own PATH
    add_to_path_if "$HOME/.rbenv/shims" head
    eval "$(rbenv init - | grep -v 'export PATH')"
fi

alias be="bundle exec"

# --- workaround for zeus bug ----------------------------------------
# see https://github.com/burke/zeus/issues/469
zeus () { ARGS=$@; command zeus "$@"; ZE_EC=$?; stty sane; if [ $ZE_EC = 2 ]; then zeus "$ARGS"; fi }

# --- heroku toolbelt ------------------------------------------------
add_to_path_if '/usr/local/heroku/bin'

# --- node.js nvm ----------------------------------------------------
source_if "$HOME/.nvm/nvm.sh"

# --- oracle ---------------------------------------------------------
if [ -n "$ORACLE_HOME" ]; then
    export NLS_LANG="AMERICAN_AMERICA.utf8"

    if [ -f "$ORACLE_HOME/sqlplus" ]; then
        # instant client
        add_to_path "$ORACLE_HOME"
        add_to_pathish LD_LIBRARY_PATH "$ORACLE_HOME" head
    else
        # full client
        add_to_path "$ORACLE_HOME/bin"
        add_to_pathish LD_LIBRARY_PATH "$ORACLE_HOME/lib" head
    fi

    add_to_pathish SQLPATH "$THIS_DIR/sqlplus" head force
fi

# -- golang ----------------------------------------------------------
if [ -d /usr/local/go ]; then
  export GOPATH="$SRC_DIR/go"
  add_to_path_if /usr/local/go/bin
  add_to_path_if "$GOPATH/bin"
fi

# --- docker-machine helpers -----------------------------------------

dm_set_docker_ip() {
  docker_host_ip=$(echo "${DOCKER_HOST}" | grep -o '[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}' )
  docker_interface_ip=$(ifconfig docker0 | grep 'inet addr' | awk '{print $2}' | awk -F: '{print $2}')
  if [[ "$docker_interface_ip" == "" ]]; then
    docker_interface_ip=$(ifconfig docker0 | grep 'inet ' | awk '{print $2}')
  fi
  export DOCKER_IP=${docker_host_ip:-$docker_interface_ip}
}

dm_on() {
  eval "$(docker-machine env default)"
  dm_set_docker_ip
  dm_status
}

dm_off() {
  unset \
    DOCKER_HOST \
    DOCKER_TLS_VERIFY \
    DOCKER_CERT_PATH \
    DOCKER_MACHINE_NAME
  dm_set_docker_ip
  dm_status
}

dm_status() {
  echo "Using docker daemon on ${DOCKER_IP}"
}

dm() {
  local \
    action \
    docker_host_ip

  action="$1"

  case "$action" in
    on)
      dm_on
      ;;
    off)
      dm_off
      ;;
    *)
      dm_status
      ;;
  esac
}

dm_set_docker_ip

# --- AWS utils ------------------------------------------------------
n2ip () {
  local query awk

  awk='{ print $0 }'

  for arg in "$@"; do
    case "$arg" in
      -q)
        awk='{print $1}'
        ;;
      *)
        query="$arg"
        ;;
    esac
  done

  aws ec2 \
      describe-instances \
      --filters "Name=tag:Name,Values=$query" Name=instance-state-name,Values=running \
    | jq -r '.Reservations[].Instances[] | [.NetworkInterfaces[0].PrivateIpAddress, (.Tags[] | select(.Key == "Name").Value), .InstanceId] | join(" ")' \
    | awk "$awk"
}

export AWS_VAULT_BACKEND=file

aws_ip_to_instance_id() {
  aws ec2 describe-instances --filters "Name=network-interface.addresses.private-ip-address,Values=$name" \
    | jq -r '.Reservations[].Instances[].InstanceId'

}

aws_dns_to_instance_id() {
  aws ec2 describe-instances --filters "Name=network-interface.addresses.private-dns-name,Values=$name" \
    | jq -r '.Reservations[].Instances[].InstanceId'
}

aws_terminate_in_asg() {
  local name id

  name="$1"

  id="$(aws_ip_to_instance_id "$name")"

  [[ -n "$id" ]] || id="$(aws_dns_to_instance_id "$name")"
  [[ -n "$id" ]] || id="$name"

  aws autoscaling terminate-instance-in-auto-scaling-group \
      --instance-id "$id" \
      --no-should-decrement-desired-capacity
}
# --- z (https://github.com/rupa/z) ----------------------------------
source_first "$SRC_DIR/z/z.sh" "$(which brew && brew --prefix)/etc/profile.d/z.sh"

# --- cask for emacs -------------------------------------------------
add_to_path_if "$HOME/.cask/bin"

export EDITOR='emacsclient -c'

# --- git completion -------------------------------------------------
source_first \
    /etc/bash_completion.d/git \
    /usr/share/bash-completion/completions/git \
    "$(which brew >/dev/null && brew --prefix)/etc/bash_completion.d/git-completion.bash"
source_if "$(which brew >/dev/null && brew --prefix)/etc/bash_completion.d/git-flow-completion.bash"

# --- kubectl completion ---------------------------------------------
if which kubectl &>/dev/null; then
  alias k=kubectl
  alias kgp='k get pod'
  alias kgj='k get job'
  alias kc='k config use-context'
  alias kcc='k config current-context'
  eval "$(kubectl completion bash)"
fi

# --- local post options ----------------------------------------------
source_if "$THIS_DIR/local.last"
source_if "$HOME/secrets/bash"
