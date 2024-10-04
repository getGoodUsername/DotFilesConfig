# to learn about setaf being used in tput, look at man 5 terminfo
# setaf is a capability code, which as far as I understand, is a special
# code defined by the terminal emulator that allows you to run the subroutine
# associated with the cap code. In this case, the output of tput setaf <integer>
# is the 256 color palette ansi escape code. More on ansi escape code here
# https://notes.burke.libbey.me/ansi-escape-codes/
# As far as I understand, all of this is just a vestige from bygone days of the "dumb terminal", where
# they were predefined limitations with said terminal that had to worked with. I guess we still use it
# because it works fine... but it sure looks ugly! BTW, here is xterm-256-color chart:
# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg

# This is where I got all the wierd ansi codes from (using tput)
#
#
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_orange="\[$(tput setaf 215)\]"
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_brightGreen="\[$(tput setaf 78)\]"
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_calmGreen="\[$(tput setaf 36)\]"
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_purple="\[$(tput setaf 63)\]"
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_pink="\[$(tput setaf 169)\]"
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_defaultTextColor="\[$(tput sgr0)\]"
# declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_errorOrange="\[$(tput setaf 202)\]"
#
#
# uncomment the above declare block and run this to get color variables as defined in function
# declare -r | grep '__Optional_Fancy__pretty_ps1__prompt_command' | sed -e 's/^declare -r __Optional_Fancy__pretty_ps1__prompt_command_colors_/local -r /' | ogcopy

# in order to have a conditionally changing PS1. https://stackoverflow.com/a/16715681/15054688
function __Optional_Fancy__pretty_ps1__prompt_command
{
	local -r exitCode="${?}"
	local -r brightGreen=$'\\[\E[38;5;78m\\]'
	local -r calmGreen=$'\\[\E[38;5;36m\\]'
	local -r defaultTextColor=$'\\[\E(B\E[m\\]'
	local -r errorOrange=$'\\[\E[38;5;202m\\]'
	local -r orange=$'\\[\E[38;5;215m\\]'
	local -r pink=$'\\[\E[38;5;169m\\]'
	local -r purple=$'\\[\E[38;5;63m\\]'


	PS1="${orange}\u${brightGreen}@${purple}\h ${pink}\w"
	PS1+="${calmGreen}" # will make ❯ green by default

	if [[ ${exitCode} -ne 0 ]]; then
		# not only display error code in errorOrange
		# but also ❯ will be the same color!
		# will override default green color.
		PS1+=" ${errorOrange}<${exitCode}>"
	fi

	PS1+="\n❯${defaultTextColor} "
	return "${exitCode}"
}

readonly -f __Optional_Fancy__pretty_ps1__prompt_command

PROMPT_COMMAND+=';__Optional_Fancy__pretty_ps1__prompt_command;'
