#!/usr/bin/bash

# this program creates a symbolic link to a new file in the home directory to the dotfiles in this dir

# .[^.] matches a file name that stars with a dot (* won't match with files that start with a dot)
	# and [^.] specifically matches to a file whose character is NOT a dot
	# therefore the file name should start with a dot, but the next character MUST NOT be a dot
	# and that is done to avoid having previous directory ".." show up

allDotFilesDir=$(pwd)
for dotfile in $allDotFilesDir/.[^.]* 
do
	ln -s $dotfile $HOME/$(basename $dotfile) 
	echo "Succesfully added $(basename $dotfile) to $HOME!"
done
