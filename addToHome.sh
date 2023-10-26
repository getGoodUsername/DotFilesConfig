#!/usr/bin/bash

# script that links dotfiles to the correct location and the dotfiles
# themselves are stored in the same folder. This allows me to avoid
# hard coding the dir of where the dotfiles are and just let the
# script figure out where we are

# https://stackoverflow.com/a/4774063/15054688
dotFilesStorageDir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

for absolutePathToDotFile in "${dotFilesStorageDir}"/.[^.]*
do
	dotFile="$(basename "${absolutePathToDotFile}")"
	linkPathToDotFile="$HOME/${dotFile}"

	if [[ "${dotFile}" = '.git' ]]; then
		echo 'Skipped .git'
		continue
	fi

	if [[ -L "${linkPathToDotFile}" ]]; then
		echo "${dotFile} already linked! skipped."
		continue
	fi	

	if [[ "${dotFile}" =~ \.swp$ ]]; then
		echo "Skipping ${dotFile} vim temp file!"
		continue
	fi

	ln -s "${absolutePathToDotFile}" "${linkPathToDotFile}"
	echo "Added: ${dotFile}!"
done
