function o --wraps=open --description 'alias o open'
    set BACK 1
    switch (uname)
    case Darwin
        set BIN "open"
    case "*"
        set BIN "xdg-open"
    end

    switch $argv
    case "*.pdf"
        set BIN "sioyek"
    case "*.md" "*.tex" "*.json"
        set BIN nvim
        set BACK 0
    end

    if test "$BACK" -gt 0
        $BIN $argv >/dev/null 2>&1 &; disown
    else
        $BIN $argv
    end
end
