shopt -s nullglob
# if hello_world* doesn't match with anything, the glob will be replaced with null.
# otherwise, if this option is not enabled, the result would be the string
# 'hello_world*'
# output null when no match with glob https://unix.stackexchange.com/a/34012