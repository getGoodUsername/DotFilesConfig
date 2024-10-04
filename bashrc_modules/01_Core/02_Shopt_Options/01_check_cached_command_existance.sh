shopt -s checkhash

# ever remove a duplicate command from your PATH, and then try
# to run the command again, only for bash to tell you that it errored
# out because the command doesn't exist!?!?
# never again! Bash will check that the cached location of the command,
# every time, and see if it is still valid before running!

# for more info: https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html