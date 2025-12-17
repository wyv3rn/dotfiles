function o --wraps=open --description 'alias o open'
    set PDFV zathura
    set BACK 1
    switch (uname)
    case Darwin
        set BIN open
        set PDFV sioyek
    case "*"
        set BIN xdg-open
    end

    switch $argv
    case "*.pdf"
        set BIN $PDFV
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
