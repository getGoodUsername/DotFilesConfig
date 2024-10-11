# I WILL BE IGNORING ANY DEFAULTS, AND JUST USING MY PREFERRED DEFAULTS
function __Core::Environment_Variables::path::impl
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

# NOTE, often .profice or /etc/profile or .bash_login files may exist that further
# modify the PATH env var. If you don't want those modifications you must directly
# remove that configuration from those 'login' files.

__Core::Environment_Variables::path::impl
unset -f __Core::Environment_Variables::path::impl
