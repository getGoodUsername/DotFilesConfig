shopt -s globskipdots

# you know cd . or cd .., where '.' represents the current dir you
# are in, and '..' represents the parent dir
# well lets not match these guys in our globs! we very rarely mean for
# .* to match '.' and '..'

# for more info: https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html