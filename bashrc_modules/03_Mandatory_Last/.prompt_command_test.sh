# don't run this module normally, supposed to be hidden...

echo 'PROMPT_COMMAND test module, should not be ran normally!'
echo "${BASH_SOURCE[0]} will overwrite your PROMPT_COMMAND!!!!"

dog_bark ()
{
    return 42;
}

cat_meow ()
{
    return 24;
}

function start()
{
    declare -g start_time;
    start_time="${EPOCHREALTIME}"
}

function end()
{
    total_time="$(bc <<< "(${EPOCHREALTIME} - ${start_time}) * 1000")"
    echo "Time prompt command took: ${total_time} ms"
}

display_exit_code ()
{
    echo "exit code: $?"
}

PROMPT_COMMAND=';;;start
end;
'

source prompt_command_final_clean.sh