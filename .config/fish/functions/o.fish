function o --wraps=open --description 'alias o open'
    switch (uname)
        case Darwin
            open $argv
        case '*'
            xdg-open $argv
    end
end
