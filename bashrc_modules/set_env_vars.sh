# automate adding paths to PATH env var, only will add paths that are available w/o duplicates
function __set_env_vars_make_path_env_format_str
{
	# input: PIPED AS STDIN, multiline string, where each line defines a separate path
	# ex.
	# __set_env_vars_make_path_env_format_str << EOL
	# ${HOME}/bin
	# ${HOME}/.local/bin
	# ${HOME}/go/bin
	# ${HOME}/.cargo/bin
	# EOL
	#
	# output: one single line string, each path joined with ':'
	# ex.
	# "/bin:/usr/bin:/sbin:/usr/sbin:${HOME}/bin"

	finalPATH=''
	while read -r pathDir;
	do
		if [[ -d "${pathDir}" ]]; then
			finalPATH="${finalPATH}:${pathDir}"
		fi
	done < <(cat <&0 | sort -u)

	printf "%s" "${finalPATH/#:/}"
}

# I WILL BE IGNORING ANY DEFAULTS, AND JUST USING MY PREFERRED DEFAULTS
declare -x PATH;
PATH="$(__set_env_vars_make_path_env_format_str << EOF
"${HOME}/bin"
"${HOME}/.cargo/bin"
"${HOME}/go/bin"
/bin
/usr/bin
/usr/local/bin
/sbin
/usr/sbin
/usr/local/sbin
/usr/games
/usr/local/games
/snap/bin
EOF
)"