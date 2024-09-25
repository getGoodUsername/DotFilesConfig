# automate adding paths to PATH env var, only will add paths that are available w/o duplicates
function __get_new_path
{
	# input: PIPED AS STDIN, multiline string, where each line defines a separate path
	# ex.
	# __get_new_path << EOL
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
		else
			printf '%s\n' "${pathDir} does not exist! Skipped when defining PATH" 1>&2
		fi
	done < <( { cat <&0; tr ':' '\n' <<< "${PATH}"; } | sort -u )

	printf "%s" "${finalPATH/#:/}"
}