# I WILL BE IGNORING ANY DEFAULTS, AND JUST USING MY PREFERRED DEFAULTS
export PATH;
PATH="$(sed -z -e 's/\n/:/g' -e 's/:$//' << EOF
${HOME}/bin
${HOME}/.cargo/bin
${HOME}/go/bin
/bin
/usr/bin
/usr/local/bin
/sbin
/usr/sbin
/usr/local/sbin
/usr/games
/usr/local/games
/snap/bin
EOF
)"