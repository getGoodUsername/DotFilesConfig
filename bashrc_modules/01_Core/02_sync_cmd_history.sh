# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL='ignoreboth:erasedups'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=$(( 2 ** 20 ))
HISTFILESIZE=$(( HISTSIZE * 2 ))

function __sync_cmd_history_between_multiple_shells
{
	local -r exitCode="${?}"
	# sync history between shells: https://unix.stackexchange.com/a/131507
	history -a
	history -n
	return "${exitCode}" # do this so exit code from previous process doesn't get mangled
}

# if stuff already in prompt command, demarcate with ; unless already ending with ;
if [[ -n "${PROMPT_COMMAND}" ]] && grep -vq ';[[:space:]]*$' <<< "${PROMPT_COMMAND}"; then
	PROMPT_COMMAND+=';';
fi
PROMPT_COMMAND+='__sync_cmd_history_between_multiple_shells;'