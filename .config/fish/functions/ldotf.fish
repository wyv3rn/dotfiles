function ldotf --wraps lazygit --description "Launch lazygit for dotfiles repo"
    lazygit --git-dir $HOME/.dotfiles.git/ --work-tree $HOME/
end
