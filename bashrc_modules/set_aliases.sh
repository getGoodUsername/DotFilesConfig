alias mv='mv -i' # warns if move command will overwrite, add -f when using mv to force and not prompt
alias cp='cp -i' # same as mv -i
alias rm='rm -I' # warn if delete more than 3 files or recursively deleting
alias less='less -R --mouse -i --use-color' # -R allows colors from input escape chars, -i lower case matches uppercase, uppercase still only matches uppercase, --use-color enables color usage for helpful highlighting in less
alias gs='git status'
alias c='clear'
alias l='ls -lA'
alias ll='lsd \
-lA \
--group-dirs last \
--icon never \
--blocks permission --blocks user --blocks size --blocks date --blocks name \
--size short \
--date "+%b %d  %H:%M"' # lsd is ls but pretty