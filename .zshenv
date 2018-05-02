export NO_AT_BRIDGE=1 # silence some GTK warnings
export VISUAL=vim
export EDITOR="$VISUAL"

export GUROBI_HOME=~/.local/gurobi750/linux64
export PATH=~/.local/bin:~/.local/bin/Telegram:${GUROBI_HOME}/bin:$PATH
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"

alias grep='grep --color=auto'
alias feh='feh -Z.'
alias fehsvg='feh --magick-timeout 1'
alias dotf="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
alias svndiff='svn diff | vim -R -'
if type "mvim" > /dev/null; then
    alias vim="mvim -v"
fi
alias v="vim"
alias vi="vim"
alias vmf="vim \$(fzf)"
alias vrc="vim ~/.vimrc"
alias t="tmux"
alias l="ls -lh"
alias la="ls -lAh"
alias x="startx-dpi"
alias sync-root="sudo rsync -aAXHS --info=progress2 --stats --exclude={/dev/\*,/proc/\*,/sys/\*,/tmp/\*,/run/\*,/mnt/\*,/media/\*,/lost+found,/home/\*/.gvfs} /"
