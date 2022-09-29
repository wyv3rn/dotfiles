# If you come from bash you might have to change your $PATH.
if ! type "env" > /dev/null; then
    # heuristic: if the env command is not found, $PATH seems not to contain important dirs
    export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
fi

export NO_AT_BRIDGE=1 # silence some GTK warnings
export VISUAL=nvim
export EDITOR="$VISUAL"

export GUROBI_HOME=~/.local/gurobi951/linux64
export PATH=~/.ghcup/bin:~/.local/bin:~/go/bin:~/.local/bin/Telegram:${GUROBI_HOME}/bin:$PATH
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"

export FZF_DEFAULT_COMMAND='fd --type f --follow'

alias x="startx-dpi"
alias sync-root="sudo rsync -aAXHS --stats --exclude={/dev/\*,/proc/\*,/sys/\*,/tmp/\*,/run/\*,/mnt/\*,/media/\*,/lost+found,/home/\*/.gvfs} /"
alias dotf="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
alias mutt="neomutt"
alias R="R --no-save --quiet"

[ -f $HOME/.zshenv_local ] && source $HOME/.zshenv_local || true
