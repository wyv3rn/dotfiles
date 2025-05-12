function o --wraps=open --description 'alias o open'
    switch (uname)
    case Darwin
        switch $argv
        case "*.pdf"
            z $argv
        case '*'
            open $argv
        end
    case '*'
        py-open $argv
    end
end
