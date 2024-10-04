function __Core__launch_ssh_agent_load_ssh_keys__impl
{
	# source/inspo: https://stackoverflow.com/a/38619604
	# ************************ DEFAULT VALUES ************************
	local -r SSH_KEYS_DIR="${HOME}/.ssh";
	local -r SOCKET_NAME='.sshAgent_socket';

	# ************************ GET SYSTEM KEYS ************************
	local -ra all_system_keys=( "${SSH_KEYS_DIR}"/*.pub );
	if [ "${#all_system_keys[@]}" -eq 0 ]; then return 0; fi

	# ************************ LOAD SSH AGENT ************************
	local -r ssh_agent_auth_sock="${SSH_KEYS_DIR}/${SOCKET_NAME}"
	if [ ! -S "${ssh_agent_auth_sock}" ]; then
		# shellcheck disable=SC2312
		eval "$(ssh-agent -s)" # will export SSH_AUTH_SOCK env var
		ln -sf "${SSH_AUTH_SOCK}" "${ssh_agent_auth_sock}"
	fi
	# my ssh-agent is already running and communicating
	# 	through ssh_agent_auth_sock socket

	# ************************ SETUP ENV ************************
	# SSH_AUTH_SOCK is important env var, tells programs
	# where to communicate with ssh-agent to get access to keys
	export SSH_AUTH_SOCK="${ssh_agent_auth_sock}" 

	# ************************ ADD KEYS TO AGENT ************************
	# used to get around sub shell weirdness of bash. Makes it
	# easier to get exit code and modify variables like so...
	local output_of_ssh_add_file;
	output_of_ssh_add_file="$(mktemp)"; readonly output_of_ssh_add_file;

	local -i exit_code_ssh_add;
	local -a already_loaded_keys;

	ssh-add -l >| "${output_of_ssh_add_file}";
	exit_code_ssh_add=$?; readonly exit_code_ssh_add;
	if [ "${exit_code_ssh_add}" -ne 0 ]; then
		# no keys in ssh-agent currently :(    add them >:)
		ssh-add "${all_system_keys[@]%.pub}"
		rm "${output_of_ssh_add_file}"
		return 0;
	fi

	# use array for key count logic instead of wc -l to avoid nasty surprises
	# with added new lines. Overall this API is more stable and has less edge cases.
	readarray already_loaded_keys < "${output_of_ssh_add_file}"; readonly already_loaded_keys;

	# key/s have been deleted from my system, now there are zombie keys in ssh-agent
	if [ "${#already_loaded_keys[@]}" -gt "${#all_system_keys[@]}" ]; then
		ssh-add -qD # delete all identities currently in ssh-agent
	fi

	if [ "${#already_loaded_keys[@]}" -ne "${#all_system_keys[@]}" ]; then
		ssh-add "${all_system_keys[@]%.pub}"
	fi

	rm "${output_of_ssh_add_file}"
}

__Core__launch_ssh_agent_load_ssh_keys__impl
unset -f __Core__launch_ssh_agent_load_ssh_keys__impl

