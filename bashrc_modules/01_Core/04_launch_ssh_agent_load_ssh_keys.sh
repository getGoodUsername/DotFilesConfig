function __Core__launch_ssh_agent_load_ssh_keys__impl
{
	# source/inspo: https://stackoverflow.com/a/38619604
	local -r ssh_agent_auth_sock="${HOME}/.ssh/.sshAgent_socket"
	if [ ! -S "$ssh_agent_auth_sock" ]; then
		eval "$(ssh-agent -s)" # will export SSH_AUTH_SOCK 
		ln -sf "$SSH_AUTH_SOCK" "$ssh_agent_auth_sock"
	fi
	# my ssh-agent is already running and communicating
	# 	through ssh_agent_auth_sock socket

	# SSH_AUTH_SOCK is important env var, tells programs
	#	where to communicate with ssh-agent, including ssh-add
	export SSH_AUTH_SOCK="$ssh_agent_auth_sock" 

	local -r loaded_in_ssh_agent_keys_count="$(ssh-add -l | wc -l)"
	local -r available_keys_count="$(printf '%s\n' ~/.ssh/*.pub | wc -l)"

	# key count will appear to be equal when one key is available
	# and none have been added to the agent yet. ssh-add -l will
	# print out a single line to stdout (not stderr >:/) when
	# the agent has no keys. It will exit with a non zero exit code
	# which I check in the if condition to act as a final fail safe

	if [[ "$loaded_in_ssh_agent_keys_count" -ne "$available_keys_count" ]] || { ! ssh-add -l &> /dev/null; }; then
		# delete all keys for ssh-agent in case when a key pair has
		#	been deleted, it is also reflected in the ssh-agent
		ssh-add -Dq
		printf '%s\n' ~/.ssh/*.pub | sed -E 's/(.+)\.pub$/\1/' | xargs ssh-add
	fi
}

__Core__launch_ssh_agent_load_ssh_keys__impl
unset -f __Core__launch_ssh_agent_load_ssh_keys__impl

