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

    # hotfix till fish 4.0
    if string match -q -- '*ghostty*' $TERM
        set -g fish_vi_force_cursor 1
    end
end
