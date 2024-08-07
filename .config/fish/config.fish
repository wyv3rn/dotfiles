if status is-interactive
    bind \cf forward-bigword accept-autosuggestion
    bind \cb backward-bigword
    bind \cn beginning-of-line
    bind \ce end-of-line
    bind \ch backward-kill-bigword
    bind \cg kill-bigword

    # some double-bindings as a hotfix for Zed with Voyager
    bind \ef forward-bigword accept-autosuggestion
    bind \eg kill-bigword # \cg
    bind \ek kill-line # \ck
    bind \eu backward-kill-line # \cu
    bind \er history-pager # \cr

    if type -q keychain
        keychain --quiet --noask --ignore-missing --eval id_rsa id_ed25519 | source
    end

    if type -q ~/.homebrew/bin/brew
        ~/.homebrew/bin/brew shellenv fish | source
    end

    if type -q zoxide
        zoxide init fish --cmd cd | source
    end
end
