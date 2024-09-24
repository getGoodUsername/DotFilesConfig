# in order to have a more "complex" PS1. https://stackoverflow.com/a/16715681/15054688
function __prompt_command
{
	local exitCode="${?}"
	local -r orange="\[$(tput setaf 215)\]"
	local -r brightGreen="\[$(tput setaf 78)\]"
	local -r calmGreen="\[$(tput setaf 36)\]"
	local -r purple="\[$(tput setaf 63)\]"
	local -r pink="\[$(tput setaf 169)\]"
	local -r defaultTextColor="\[$(tput sgr0)\]"
	local -r errorOrange="\[$(tput setaf 202)\]"


	PS1="${orange}\u${brightGreen}@${purple}\h ${pink}\w"
	PS1+="${calmGreen}" # will make ❯ green by default

	if [[ ${exitCode} -ne 0 ]]; then
		# not only display error code in errorOrange
		# but also ❯ will be the same color!
		# will override default green color.
		PS1+=" ${errorOrange}<${exitCode}>"
	fi

	PS1+="\n❯${defaultTextColor} "

	# sync history between shells: https://unix.stackexchange.com/a/131507
	history -a
	history -n
}