# -*- Mode: shell-script -*-

# --- utility functions ----------------------------------------------

# determine if $dir already exists in PATH-like variable $var
function in-path-var()
{
    var="$1"
    dir="$2"

    awk -F: '{ for (i=1; i<=NF; i++) print $i }' <<<"$var" | grep -q "^${dir}\$"
}

# add a directory to a PATH-like var if it's not already there
# if location is "head", add it to the head of the list
# if force is "force", add it even if it already exists in the list
function add-to-pathish()
{
    local varname="$1"
    local dir="$2"
    local location="$3"
    local force="$4"

    local value=$(eval "echo \$${varname}")

    if [ "$force" = "force" ] || ! in-path-var "$value" "$dir"; then
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
function add-to-path()
{
    local dir="$1"
    local location="$2"
    local force="$3"

    add-to-pathish PATH "$dir" "$location" "$force"
}

# add-to-path a directory if it exists
function add-to-path-if()
{
    local dir="$1"
    local location="$2"
    local force="$3"

    [ -d "$dir" ] && add-to-path "$dir" "$location" "$force"
}

# Source a file if it exists.
#
# Return 0 if the file exists, 1 otherwise.
function source-if()
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
function source-first()
{
    for file in "$@"; do
        source-if "$file" && return 0
    done

    return 1
}

# --- local pre options ----------------------------------------------
source-if "$ETC_DIR/local.first"

# --- configuration variables ----------------------------------------

# where I keep source code for things
: ${SRC_DIR:="$HOME/src"}

# --- shell options --------------------------------------------------
[ "$SHELL" == "/bin/bash" ] && shopt -s checkwinsize

[ -d "$HOME/bin" ] && add-to-path "$HOME/bin" head force

# make sure color escape codes work in less
if ! grep -qi "r" <<<"$LESS"; then
    export LESS="$LESS -r"
fi

export PS1="\h:\W \u\$ "
export HISTCONTROL='ignoreboth'
# ls color output
export CLICOLOR=1

# --- python virtualenvs ---------------------------------------------
source-first /usr/local/bin/virtualenvwrapper.sh /etc/bash_completion.d/virtualenvwrapper

# -- pyenv -----------------------------------------------------------
if which pyenv > /dev/null; then
    eval "$(pyenv init -)";
    export PYENV_ROOT="$HOME/.pyenv"
    add-to-path "$PYENV_ROOT/bin" head

    if which pyenv-virtualenv-init > /dev/null; then
        eval "$(pyenv virtualenv-init -)";
    fi
fi

# --- ruby rbenv -----------------------------------------------------
if which rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi

# --- workaround for zeus bug ----------------------------------------
# see https://github.com/burke/zeus/issues/469
zeus () { ARGS=$@; command zeus "$@"; ZE_EC=$?; stty sane; if [ $ZE_EC = 2 ]; then zeus "$ARGS"; fi }

# --- node.js nvm ----------------------------------------------------
source-if "$HOME/.nvm/nvm.sh"

# --- oracle ---------------------------------------------------------
if [ -n "$ORACLE_HOME" ]; then
    export NLS_LANG="AMERICAN_AMERICA.utf8"

    if [ -f "$ORACLE_HOME/sqlplus" ]; then
        # instant client
        add-to-path "$ORACLE_HOME"
        add-to-pathish LD_LIBRARY_PATH "$ORACLE_HOME" head
    else
        # full client
        add-to-path "$ORACLE_HOME/bin"
        add-to-pathish LD_LIBRARY_PATH "$ORACLE_HOME/lib" head
    fi

    add-to-pathish SQLPATH "$ETC_DIR/sqlplus" head force
fi

# --- z (https://github.com/rupa/z) ----------------------------------
source-first "$SRC_DIR/z/z.sh" "$(brew --prefix)/etc/profile.d/z.sh"

# --- cask for emacs -------------------------------------------------
add-to-path-if "$HOME/.cask/bin"

# --- git completion -------------------------------------------------
source-first \
    /etc/bash_completion.d/git \
    /usr/share/bash-completion/completions/git \
    "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
source-if "$(brew --prefix)/etc/bash_completion.d/git-flow-completion.bash"

# --- local post options ----------------------------------------------
source-if "$ETC_DIR/local.last"
