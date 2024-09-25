# for all the cool fzf key bindings
declare -r __fzf_setup_keybindings_script_fname=
if [[ -e /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    # zoxide doesn't handle -- like cd (don't think it has options like cd) and will error out if -- is present
	if type zoxide &>/dev/null; then
        # shellcheck source=/usr/share/doc/fzf/examples/key-bindings.bash
		source <(sed $'s/printf \'cd -- %q\' "$dir"/printf \'__zoxide_z %q\' "$dir"/' /usr/share/doc/fzf/examples/key-bindings.bash)
	else
		source /usr/share/doc/fzf/examples/key-bindings.bash
	fi
fi