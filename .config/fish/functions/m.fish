function m --wraps='mpv $(find $HOME/Music -name "*.m3u" | fzf)' --description 'alias m=mpv $(find $HOME/Music -name "*.m3u" | fzf)'
    mpv $(find $HOME/Music -type f | fzf) $argv
end
