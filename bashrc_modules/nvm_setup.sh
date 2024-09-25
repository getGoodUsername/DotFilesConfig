# have to do `node use --lts` when you get around to actually wanting to use nodejs
# in a shell. due to --no-use option. Done to speed up drastically the spinning up of a new shell
export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm, --no-use will stop it from doing all the other stuff to actually have node exec in path
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion