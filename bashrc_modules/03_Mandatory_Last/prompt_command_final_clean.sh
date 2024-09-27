# find all ';' sequences that  are not being escaped with a
# forward slash, and replace them with just a new line
PROMPT_COMMAND="$(sed -E 's/([^\]);+/\1;\n/g' <<< "${PROMPT_COMMAND}")"

# setting up code to keep hold of exit codes
# shellcheck disable=SC2016
__prompt_command_final_clean_keep_return_val_head='__prompt_command_final_clean_exit_code_store="${?}"
function __prompt_command_final_clean_exit_code_propagator
{
    return "${__prompt_command_final_clean_exit_code_store}"
}'
__prompt_command_final_clean_unset_exit_code_helper='unset -v __prompt_command_final_clean_exit_code_store __prompt_command_final_clean_exit_code_propagator'

PROMPT_COMMAND="${__prompt_command_final_clean_keep_return_val_head}
$(sed -E 's/(^.*$)/__prompt_command_final_clean_exit_code_propagator;\n\1/' <<< "${PROMPT_COMMAND}")
${__prompt_command_final_clean_unset_exit_code_helper}
"

unset -v __prompt_command_final_clean_keep_return_val_head __prompt_command_final_clean_unset_exit_code_helper
# All this is done because when my modules append to PROMPT_COMMAND
# IT SHOULD (as according to the README.md), add the new command/s
# flanked with ';' on both the end and start of the command/s group
# like ;echo hello world; OR ;_func_to_run;_another_func_to_run;
# if not other non modules that also modify PROMPT_COMMAND, and assume
# nothing will be there, WILL just append to PROMPT_COMMAND without a
# semicolon and therefore PROMPT_COMMAND will turn to gibberish
# Ex. PROMPT_COMMAND='_func;';
# then another program adds to PROMPT_COMMAND like so:
# PROMPT_COMMAND='${PROMPT_COMMAND}_another_thing';
# Then we are fucked. And end up with
# '_func_another_thing' which is gibberish!!!!
