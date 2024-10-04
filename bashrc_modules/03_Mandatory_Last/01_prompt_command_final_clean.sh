# *********************************** WARNING ***********************************
# I ASSUME the current state of PROMPT_COMMAND to be DEAD SIMPLE!!!!!!!!!
# By "DEAD SIMPLE", I mean:
#
# ********************************** DA RULES **********************************
# 1. EVERY COMMAND LOOKS LIKE:
#   ;?(exec name|shell function name)[;\n][[:space:]]*
#       Optional ';' at start due to explicit instructions from README.md
#       when adding a a command to PROMPT_COMMAND. README.md says command
#       should be added like so: ';command;'. Optional since other programs
#       may also change PROMPT_COMMAND and not in the way like enforced by
#       my rules.
#
# 2. COMMAND_PROMPT CAN BE A MULTILINE STRING IF YOU WANT
#       There can also be empty lines between commands to act as logical
#       separators for easier reading.
#
#       NOTE, this logical separation might be removed upon processing of
#       PROMPT_COMMAND! This will not have an effect on the actual execution
#       unless you have violated any other of the stated rules.
#
# 3. NO ARGUMENTS ARE FED TO AN EXECUTABLE OR SHELL FUNCTION
#       EXAMPLE: `echo 'your text'` is NOT ALLOWED
#
# 4. NO MULTILINE COMMANDS
#       THOUGH you can have more than one command on a single line by using
#       ';' as a separator) BUT you CAN NOT have one command on more than
#       one line.
#
# 5. NO FUNCTION DEFINITIONS WITHIN PROMPT_COMMAND
#
# 6. NO CHAIN OF COMMANDS WITHIN PROMPT_COMMAND THAT DEPEND ON EACH
#   OTHERS EXIT CODE TO RUN PROPERLY.
#       Example:
#       command_0; command_1_depends_on_exit_code_of_command_0;
#       This is not possible since I will run an exit code propagator function
#       at the end of every command in PROMPT_COMMAND to propagate the exit
#       code of the last ran user command.
#
# 7. EVERY USE OF ';' DESIGNATES THE END OF A COMMAND.
#       Yes, that means the common usage of \; in the find cmdline utility
#       will not work as expected.
#
# 8. NO USE OF FILE REDIRECTION
#       > file, 1>&2, 2>/dev/null, etc.
#
# 9. NO COMMENTS
#
# 10. NO VARIABLE DECLARATIONS OR SETTING
#       No var='g', or declare var;
#
# 11. EXECUTABLE/SHELL FUNCTION NAMES ONLY CONTAIN CHARS: [a-zA-Z0-9_]
#       'hello world' (hello\ world) is not a valid executable name
#       'my\;weird\&exec' is also not a valid executable name
#       'not-even-hyphens' is not a valid executable name
#
# ********************************* END OF DA RULES *********************************
#
# RATIONALE:
#   I intentionally make the requirements strict to avoid having to create a
#   mini bash lexical parser. It quickly gets complicated & unmaintainable to
#   correctly parse a non trivial command. I just want to make sure my added
#   commands will run as intended.
#
# GETTING AROUND THE RULES:
#   If you need any of the unallowed functionality, define long living global
#   function outside of PROMPT_COMMAND and then call that function within
#   PROMPT_COMMAND.
#
# TLDR:
#   If the string you are appending to PROMPT_COMMAND looks more complicated than:
#     ';command;'
#   OR
#     ';command_0;     command_1;'
#   OR
#     ';
#     command_0
#
#     command_1
#     ;'
#   IT IS PROBABLY UNALLOWED.
#
# ************************* DON'T TELL ME I DIDN'T WARN YOU! *************************


function __Mandatory_Last__prompt_command_final_clean__main
{
    if [ -z "${PROMPT_COMMAND}" ]; then return 0; fi

    # ensure that the exit code of the last ran user command will be the exit
    # code seen by every command in PROMPT_COMMAND, and by the interactive shell
    # when PROMPT_COMMAND is done running and gives back control to the user.
    # shellcheck disable=SC2016
    local -r exit_code_propagator_definition='eval "$(printf "function __Mandatory_Last__prompt_command_final_clean__exit_code_propagator { return %d; }" $?)"'

    # pipeline explained:
    # 1. Replace all consecutive sequences of characters that are NOT part of
    #   the character class which defines the allowable executable/shell function
    #    names (look at DA RULES) with ';\n<exit code propagator>\n'
    #
    #       PROMPT_COMMAND is 'piped' into sed, wrapped with two ';', to make the
    #       following assurances:
    #
    #           a) Every command will always end with ';'. This can not otherwise
    #           be assured by this sed command unless PROMPT_COMMAND is appended
    #           with ';' (or ANY OTHER NON exec/shell func char). If the last char
    #           in PROMPT_COMMAND IS an exec/shell func char, then pattern won't match
    #           and replace with ';\n<exit code propagator>\n'
    #               i) this also ensures the last line of the sed output will be
    #               '<exit code propagator>\n'
    #
    #           b) The first characters output by this sed command will ALWAYS BE
    #           ';\n'. PROMPT_COMMAND is pre-pended with ';' (can also be ANY OTHER NON
    #           exec/shell func char) in order to make sure sed pattern matches every
    #           single time at the VERY beginning of PROMPT_COMMAND and therefore always
    #           outputs ';\n' as the first two chars.
    #           This comes in handy for the next pipeline step.
    #
    #       I used sed with -z to allow sed to match \n in order to squeeze the output
    #       as much as possible and to insure I at most have only a single line with
    #       only ';\n'
    # 2. Since I am assured the first line is always ';\n', and I know that this is seen
    #   as an error (NOT a NO OP) by bash, I will just remove it.
    #       The first line ends up being '<exit code propagator>\n'

    PROMPT_COMMAND="$(
    echo "${exit_code_propagator_definition}"
    sed -Ez 's/[^a-zA-Z0-9_]+/;\n__Mandatory_Last__prompt_command_final_clean__exit_code_propagator;\n/g' \
        <<< ";${PROMPT_COMMAND};" \
        | tail -n +2 \
    )"
    readonly PROMPT_COMMAND
}

__Mandatory_Last__prompt_command_final_clean__main
unset -f __Mandatory_Last__prompt_command_final_clean__main