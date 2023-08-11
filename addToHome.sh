#!/usr/bin/bash

# this program creates a symbolic link to a new file in the home directory to the dotfiles in this dir
# since the script should be in the dir of all the dotfiles
	# dirname "$0" ensures that from wherever the script is ran, the right
	# directory is chosen to source the dot files
allDotfilesDir=$(dirname "$0")

# .[^.] matches a file name that stars with a dot (* won't match with files that start with a dot)
	# and [^.] specifically matches to a file whose character is NOT a dot
	# therefore the file name should start with a dot, but the next character MUST NOT be a dot
	# and that is done to avoid having previous directory ".." show up
for fullDotfileName in $allDotfilesDir/.[^.]* 
do
	dotfile=$(basename $fullDotfileName)

	if [[ $dotfile = '.git' ]]; then
		echo skipped .git
		continue
	fi

	ln -s $fullDotfileName $HOME/$dotfile 
	echo "Succesfully added $dotfile to $HOME!"
done
