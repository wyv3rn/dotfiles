function o --wraps=open --description 'alias o open'
    switch (uname)
        case Darwin
            open $argv
        case '*'
            py-open $argv
    end
end
