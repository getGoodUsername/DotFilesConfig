shopt -s checkjobs

# you forgot you put a job in the background
# you then go to exit you shell, OH NO, the job hadn't finished yet!!!
# you have to restart your job OR WORSE, have to go back to a stable state
# NO LONGER!
# if you have a job running in the background and try to exit
# bash will warn you once about it and keep the shell alive
# if you run exit again, your command is respected and the shell
# does quit now.

# for more info: https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html