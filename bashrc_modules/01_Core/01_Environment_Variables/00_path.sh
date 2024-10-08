# I WILL BE IGNORING ANY DEFAULTS, AND JUST USING MY PREFERRED DEFAULTS
function __Core__Environment_Variables__path__impl
{
    local -r IFS=':'
    local -ar target_path_dirs=(
        "${HOME}"/bin
        "${HOME}"/.cargo/bin
        "${HOME}"/go/bin
        /bin
        /usr/bin
        /usr/local/bin
        /sbin
        /usr/sbin
        /usr/local/sbin
        /usr/games
        /usr/local/games
        /snap/bin
    )
    local -a available_path_dirs;

    for dir in "${target_path_dirs[@]}"; do
        if [[ -d "${dir}" && -x "${dir}" ]]; then available_path_dirs+=("${dir}"); fi
    done

    export PATH;
    PATH="${available_path_dirs[*]}";
}

__Core__Environment_Variables__path__impl
unset -f __Core__Environment_Variables__path__impl