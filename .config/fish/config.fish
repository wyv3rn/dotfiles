if status is-interactive
    set fish_cursor_default     block      blink
    set fish_cursor_insert      line       blink
    set fish_cursor_replace_one underscore blink
    set fish_cursor_visual      block

    if type -q keychain
        keychain --quiet --noask --ignore-missing --eval id_rsa id_ed25519 | source
    end

    if type -q ~/.homebrew/bin/brew
        ~/.homebrew/bin/brew shellenv fish | source
    end

    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

    if type -q batman
        alias man batman
    end
end

# abbreviations
function multicd
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --command cd --function multicd

function last_history_item; echo $history[1]; end
abbr --add !! --position anywhere --function last_history_item
