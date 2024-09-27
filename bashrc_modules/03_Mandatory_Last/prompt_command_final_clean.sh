function __prompt_command_final_clean_main
{
    if [ -z "${PROMPT_COMMAND}" ]; then return 0; fi

    # setting up code to keep hold of exit codes even if set prompt commands mangle
    # all over said code, or if a command dependent on the exit code is not first in
    # line in PROMPT_COMMAND this will still insure that it gets the "right" code.

    # shellcheck disable=SC2016
    local -r keep_return_val_head='
__prompt_command_final_clean_exit_code_store="${?}"
function __prompt_command_final_clean_exit_code_propagator
{
    return "${__prompt_command_final_clean_exit_code_store}"
}
'
    # multiline strings are weird here so they don't look as
    #  weird when inspecting PROMPT_COMMAND in interactive shell
    local -r unset_exit_code_helper='
unset -v \
    __prompt_command_final_clean_exit_code_store \
    __prompt_command_final_clean_exit_code_propagator
'

    # find all ';' sequences that are not being escaped with a
    # forward slash, and replace them with just a new line
    PROMPT_COMMAND="$(sed -E 's/([^\]);+/\1;\n/g' <<< "${PROMPT_COMMAND}")"

    PROMPT_COMMAND="
${keep_return_val_head}
$(sed -E 's/(^.*$)/__prompt_command_final_clean_exit_code_propagator;\n\1/' <<< "${PROMPT_COMMAND}")
${unset_exit_code_helper}
"
    readonly PROMPT_COMMAND # no more editing of PROMPT_COMMAND is allowed after sourcing this module!!!!

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
}

__prompt_command_final_clean_main
unset -f __prompt_command_final_clean_main