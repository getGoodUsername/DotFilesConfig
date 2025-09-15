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

# This is where I got all the weird ansi codes from (using tput)
#
#
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_orange="\[$(tput setaf 215)\]"
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_brightGreen="\[$(tput setaf 78)\]"
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_calmGreen="\[$(tput setaf 36)\]"
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_purple="\[$(tput setaf 63)\]"
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_pink="\[$(tput setaf 169)\]"
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_defaultTextColor="\[$(tput sgr0)\]"
# declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_errorOrange="\[$(tput setaf 202)\]"
#
#
# uncomment the above declare block and run this to get color variables as defined in function
# declare -r | grep '__Optional_Fancy::pretty_ps1::prompt_command' | sed -e 's/^declare -r __Optional_Fancy::pretty_ps1::prompt_command_colors_/local -r /' | ogcopy

# in order to have a conditionally changing PS1. https://stackoverflow.com/a/16715681/15054688
function __Optional_Fancy::pretty_ps1::prompt_command
{
	local -r exitCode="${?}"
	local -r brightGreen=$'\\[\E[38;5;78m\\]'
	local -r calmGreen=$'\\[\E[38;5;36m\\]'
	local -r defaultTextColor=$'\\[\E(B\E[m\\]'
	local -r errorOrange=$'\\[\E[38;5;202m\\]'
	local -r orange=$'\\[\E[38;5;215m\\]'
	local -r pink=$'\\[\E[38;5;169m\\]'
	local -r purple=$'\\[\E[38;5;63m\\]'

	# ************************** working directory (\w) presentation shortening **************************
	local -r currWorkDir="${PWD/#${HOME}/\~}";
	local -r currWorkDirPrefixPS1="${USER}@${HOSTNAME} "; # don't forget to update when \w prefix in PS1 changes
	local -ri maxCurrWorkDirLength=$(( COLUMNS - ${#currWorkDirPrefixPS1} ));

	if [[ "${maxCurrWorkDirLength}" -lt "${#currWorkDir}" && "${maxCurrWorkDirLength}" -gt 0 ]]; then
	{
		# - 4 since after bash dir trim, dirs get replaced with '.../'
		local -ri maxCurrWorkDirLengthPostDirTrim=$(( maxCurrWorkDirLength - 4 ));
		local -r onlyForwardSlashWorkDir=${currWorkDir//[^\/]};
		local -ri dirCount=${#onlyForwardSlashWorkDir}; # can be 0 if $PWD -eq $HOME and therefore currWorkDir='~'
		local -i charsRemovedFromWorkDir=0;

		PROMPT_DIRTRIM=${dirCount};
		while [[ \
			"${PROMPT_DIRTRIM}" -gt 0 \
			&& $(( ${#currWorkDir} - charsRemovedFromWorkDir )) -gt ${maxCurrWorkDirLengthPostDirTrim} \
		]] && read -r -d '/' dir; do
		{
			# + 1 to account for not displayed '/' deliminator
			charsRemovedFromWorkDir=$(( charsRemovedFromWorkDir + 1 + ${#dir} ))
			PROMPT_DIRTRIM=$(( PROMPT_DIRTRIM - 1 ))
		}
		done <<< "${currWorkDir/*(\~)\//}/"
		# remove first '/' (along with maybe a ~) from currWorkDir so `read -d '/'` first input is not empty
		# add '/' to end so `read -d '/'` last input is last dir, not second to last dir

		# NOTE, when PROMPT_DIRTRIM=0, bash seems to ignore. good! don't have to handle that case!
	}
	else
		# default to show full dirs in '\w'
		PROMPT_DIRTRIM=0;
	fi
	# ************************** END OF working directory (\w) presentation shortening **************************

	PS1="${orange}\u${brightGreen}@${purple}\h ${pink}\w"
	PS1+="${calmGreen}" # will make ❯ green by default

	if [[ ${exitCode} -ne 0 ]]; then
		# not only display error code in errorOrange
		# but also ❯ will be the same color!
		# will override default green color.
		PS1+=" ${errorOrange}<${exitCode}>"
	fi

	# $VIRTUAL_ENV_PROMPT is an env var set when setting up a python
	# virtual env. It usually is just: '(venv) '
	# usually when setting up the virt env, python will change the PS1
	# but since using PROMPT_COMMANMD, this doesn't change anything.

	# shellcheck disable=SC2154
	PS1+="\n${VIRTUAL_ENV_PROMPT}❯${defaultTextColor} "

	return "${exitCode}"
}

readonly -f __Optional_Fancy::pretty_ps1::prompt_command

PROMPT_COMMAND+=';__Optional_Fancy::pretty_ps1::prompt_command;'
