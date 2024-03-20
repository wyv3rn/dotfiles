if status is-interactive
    bind \cf forward-bigword accept-autosuggestion
    bind \cb backward-bigword
    bind \cn beginning-of-line
    bind \ce end-of-line
    bind \ch backward-kill-bigword
    bind \cg kill-bigword

    if type -q keychain
        keychain --noask --ignore-missing --eval id_rsa id_ed25519 | source
    end

    if type -q zoxide
        zoxide init fish --cmd cd | source
    end
end
