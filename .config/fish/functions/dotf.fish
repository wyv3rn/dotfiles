function dotf --wraps='/usr/bin/git --git-dir=/home/dschatz/.dotfiles.git/ --work-tree=/home/dschatz' --description 'alias dotf /usr/bin/git --git-dir=/home/dschatz/.dotfiles.git/ --work-tree=/home/dschatz'
  /usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME $argv
end
