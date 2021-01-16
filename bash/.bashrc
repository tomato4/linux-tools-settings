# basename of pwd
PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w"
# colors git status
PS1+="\[\$(git_color)\]"
# prints current branch
PS1+="\$(git_branch)"
# '#' for root, else '$'
PS1+="\[\033[00m\]\$ "
export PS1
