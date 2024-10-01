# NOTE:
# I assume the current state of PROMPT_COMMAND to be DEAD SIMPLE!!!!!!!!!
#
# 1. I ASSUME EVERY COMMAND LOOKS LIKE:
#   ;?(command_name|shell function)[;\n][[:space:]]*
#       Optional ';' at start due to explicit instructions from README.md
#       when adding a a command to PROMPT_COMMAND. README.md says command
#       should be added like so: ';command;'. Optional since other programs
#       may also change PROMPT_COMMAND and not in the way like enforced by
#       my rules.
#
# 2. I ASSUME THAT COMMAND_PROMPT MAY BE A MULTILINE STRING
#       There can also be empty lines between commands to act as logical
#       separators for easier reading.
#
#       NOTE, this logical separation might be removed upon processing of
#       PROMPT_COMMAND! This will not have an effect on the actual execution
#       unless you have violated any other of the stated rules.
#
# 3. I ASSUME NO ARGUMENTS ARE FED TO AN EXECUTABLE OR SHELL FUNCTION
#
# 4. I ASSUME NO MULTILINE COMMANDS
#       THOUGH you can have more than one command on a single line by using
#       ';' as a separator) BUT you CAN NOT have one command on more than
#       one line.
#
# 5. I ASSUME NO FUNCTION DEFINITIONS WITHIN PROMPT_COMMAND
#
# 6. I ASSUME THERE ARE NO CHAIN OF COMMANDS WITHIN PROMPT_COMMAND THAT
#       DEPEND ON EACH OTHERS EXIT CODE TO RUN CORRECTLY.
#       Example:
#       command_0; command_1_depends_on_exit_code_of_command_0;
#       This is not possible since I will run an exit code propagator function
#       at the end of every command in PROMPT_COMMAND to propagate the exit
#       code of the last ran user command.
#
# 7. I ASSUME EVERY USE OF ';' DESIGNATES THE END OF A COMMAND.
#       Yes, that means the common usage of \; in the find cmdline utility
#       will not work as expected.
#
# 8. I ASSUME NO USE OF FILE REDIRECTION (> file, 1>&2, 2>/dev/null, etc.)
#
# 9. I ASSUME NO COMMENTS
#
# 10. I ASSUME NO VARIABLE DECLARATIONS OR SETTING
#       No var='g', or declare var;
#
# 11. I ASSUME EXECUTABLE NAMES ONLY CONTAIN CHARS: [a-zA-Z0-9_]
#       'hello world' (hello\ world) is not a valid executable name
#       'my\;weird\&exec' is also not a valid executable name
#
# I intentionally make the requirements strict to avoid having to create a
# mini bash interpreter. It quickly gets complicated to correctly
# parse a non trivial command. If you need any of the unallowed functionality,
# please just make define a function outside of PROMPT_COMMAND and proceed
# to call that function within PROMPT_COMMAND
#
#
#
#
# TLDR:
# If the string you are appending to PROMPT_COMMAND looks more complicated than:
#   ';command;'
# OR
#   ';command_0;     command_1;'
# OR
#   ';
#   command_0
#
#   command_1
#   ;'
# IT IS PROBABLY UNALLOWED.
#
#
# ***DON'T TELL ME I DIDN'T WARN YOU!***


function __Mandatory_Last__prompt_command_final_clean__main
{
    if [ -z "${PROMPT_COMMAND}" ]; then return 0; fi

    # ensure that the exit code of the last ran user command will be the exit
    # code seen by every command in PROMPT_COMMAND, and by the interactive shell
    # when PROMPT_COMMAND is done running and gives back control to the user.
    # shellcheck disable=SC2016
    local -r exit_code_propagator_definition='eval "$(printf "function __Mandatory_Last__prompt_command_final_clean__exit_code_propagator { return %d; }" $?)"'

    # pipeline explained:
    # 1.Allow next sed pipeline command to read multiline string as if a single
    #   long line by replacing all new line chars with null chars
    #   I use a null character as I ASSUME (hopefully sanely?!!!) that
    #   PROMPT_COMMAND will not have any null characters of its own
    #
    # 2. sed takes every sequence of the pair, escape char + null char
    #   (null char used to be new line) and deletes it.'
    #   After playing around with the bash interactive interpreter,
    #   this seems like what bash is more or less doing when interpreting a multiline
    #   command
    #
    # 3. find all sequences of unescaped ';' that are longer than one and squeeze
    #   them to a single ';'. Done since there might be extra ';' due to the explicit
    #   instruction of adding commands to PROMPT_COMMAND with ';' flanked on both
    #   the start and end of the command string (look at README.md)
    #   Along with that, the sed command also appends a new line to each of the single
    #   remaining ';' to logically separate commands into their own line.
    #   Note, commands that don't end with ';' should already be on separate lines
    #   as otherwise bash would define that as an error. I will not actively try to
    #   mend mistakes made in steps taken before this one!
    #
    # 4. give back all the newlines that now act to either logically separate commands
    #   or even, from bashes perspective, actually act as command separator
    #   char like ';'
    #
    # 5. append exit code propagator function at the end of every non empty line.
    #   The distinction of 'non empty line' is important to make sure that we don't
    #   run the exit code propagator function more times than needed. Lines with
    #   only '\n' are counted by sed as empty.
    PROMPT_COMMAND="$(
    echo "${exit_code_propagator_definition}"
    echo '__Mandatory_Last__prompt_command_final_clean__exit_code_propagator'
    tr '\n' '\0' <<< "${PROMPT_COMMAND}" \
        | sed -E 's/\\\x0//g' \
        | sed -E 's/([^\;];+)[[:space:]]+/\1/g' \
        | sed -E 's/([^\;]);+/\1;\x0/g' \
        | tr '\0' '\n' \
        | sed -E 's/(^.+$)/\1\n__Mandatory_Last__prompt_command_final_clean__exit_code_propagator;/'
    )"
    # readonly PROMPT_COMMAND

    # All this is done because when my modules append to PROMPT_COMMAND IT SHOULD
    # (as according to the README.md), add the new command/s flanked with ';' on
    # both the end and start of the command/s group.
    #
    # Example:
    # ;echo hello world;
    # ;_func_to_run;_another_func_to_run;
    #
    # This is done as a defensive strategy against other programs that will
    # modify PROMPT_COMMAND, appending their part to either the start or end
    # of the PROMPT COMMAND string.
    #
    # Example:
    # PROMPT_COMMAND='_func;';
    # then another program adds to PROMPT_COMMAND like so:
    # PROMPT_COMMAND='${PROMPT_COMMAND}_another_thing';
    # Now we are fucked. both '_another_thing' and '_func' are assumed to be valid
    # commands on their own but '_func_another_thing' is now treated as a new single
    # entity which will often be gibberish!!!
}

__Mandatory_Last__prompt_command_final_clean__main
unset -f __Mandatory_Last__prompt_command_final_clean__main