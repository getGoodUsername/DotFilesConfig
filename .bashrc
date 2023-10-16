# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion



######################################### MY ADDED STUFF ############################################
# in order to have a more "complex" PS1. https://stackoverflow.com/a/16715681/15054688
function __prompt_command
{
	local exitCode="${?}"
	local red="\[$(tput setaf 160)\]"
	local orange="\[$(tput setaf 215)\]"
	local brightGreen="\[$(tput setaf 78)\]"
	local calmGreen="\[$(tput setaf 36)\]"
	local purple="\[$(tput setaf 63)\]"
	local pink="\[$(tput setaf 169)\]"
	local defaultTextColor="\[$(tput sgr0)\]"
	local errorOrange="\[$(tput setaf 202)\]"


	PS1="${orange}\u${brightGreen}@${purple}HP800G2 ${pink}\w"
	PS1+="${calmGreen}" # will make ❯ green by default

	if [[ ${exitCode} -ne 0 ]]; then
		# not only display error code in errorOrange
		# but also ❯ will be the same color!
		# will override default green color.
		PS1+=" ${errorOrange}<${exitCode}>"
	fi

	PS1+="\n❯${defaultTextColor} "
}
# enables more complex PS1
PROMPT_COMMAND=__prompt_command


eval $(ssh-agent -s)
ssh-add ~/.ssh/github

export PATH="$PATH:$HOME/bin:$HOME/go/bin:$HOME/.cargo/bin"
export MANPAGER='less -R --mouse' # make default pager that man uses less with mouse support
export EDITOR='vim' # make default editor for multiline command vim. use ctrl-x ctlr-e 
export TODO_TRACKER_DIR="${HOME}/Documents/TodoTracker"
alias ll='exa -alh' # exa is modern ls with more features. most helpfully, it has pretty colors!
alias mv='mv -i' # warns if move command will overwrite, add -f when using mv to force and not prompt
alias less='less -R --mouse' # -R allows colors, --mouse allows scorlling with mouse wheel!
alias gs='git status'
alias c='clear'

source ~/.bash.d/cht.sh # autocompletion for cht.sh
source /usr/share/doc/fzf/examples/key-bindings.bash # for all the cool fzf key bindings
shopt -s globstar    # Allow ** for recursive matches ('lib/**/*.rb' => 'lib/a/b/c.rb')
shopt -s nullglob # prevents an error in case a glob does not match to anything by 
		  	# outputing nothing if nothing matches! https://unix.stackexchange.com/a/34012
set -o noclobber  # does not allow to overwrite exisiting file with '>' output redirection unless
			# unless specified with '>|'. Useful to avoid shooting yourself in the foot!

# the first test is so that will only output this block of text if not currently in a tmux session
# do in paren group to avoid having ${tmuxls} var later in current bash script		  
[[ -z "${TMUX}" ]] && (
	tmuxls=$(tmux ls 2> /dev/null) 	# if no session running, tmux will output error
						# this error will be sent to stderr and nothing
						# will come out of stdout. And if there is a session
						# running nothing usually will come from stderr
						# and stdout will have something
	echo ''; # just a new line						
	[[ -n "${tmuxls}" ]] &&
		echo -e "Currently running tmux session(s):\n${tmuxls}" ||
		echo "No tmux session(s) running. Open one with: tmux [new -s <session name>]"
)
####################################### EOF MY ADDED STUFF ##########################################
