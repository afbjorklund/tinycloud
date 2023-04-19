case "$TERM" in
    xterm-color) color_prompt=yes;;
    *-256color)  color_prompt=256;;
esac
case "$COLORTERM" in
    truecolor) color_prompt=true;;
esac
# Lima PS1: set color to lime
if [ "$color_prompt" = true ]; then
    PS1='\[\033[38;2;192;255;0m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
elif [ "$color_prompt" = 256 ]; then
    PS1='\[\033[38;5;154m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
elif [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;92m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt
