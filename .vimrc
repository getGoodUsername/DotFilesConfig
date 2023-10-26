set autoindent " auto indent.
set nowrap " make if lines are longer than col space, just truncate instead of displaying on new line
autocmd TextChanged,TextChangedI <buffer> silent write " enable autosave
