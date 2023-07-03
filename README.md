Setup:
```
git clone --bare https://github.com/wyv3rn/dotfiles.git $HOME/.dotfiles.git
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'
dotfiles checkout
dotfiles submodule update --init --recursive
dotfiles config --local status.showUntrackedFiles no
dotfiles remote set-url origin git@github.com:wyv3rn/dotfiles.git
```

[Catppuccin Wallpapers](https://github.com/Gingeh/wallpapers): Copyright (c) 2021 Catppuccin
