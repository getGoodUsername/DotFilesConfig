if type -P bun > /dev/null; then
	export BUN_INSTALL="${HOME}/.bin";
fi

# it is important that the path script gets
# added first or else the `type -P bun` check
# WILL fail. If BUN_INSTALL is not appearing
# in you `env`, make sure that 00_path.sh
# is configured correctly!
