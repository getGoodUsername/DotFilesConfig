shopt -s globstar # Allow ** for recursive matches ('lib/**/*.rb' => 'lib/a/b/c.rb')
shopt -s nullglob # output null when no match with glob https://unix.stackexchange.com/a/34012
set -o noclobber  # overwriting of file only allowed with >|, cant use just '>'