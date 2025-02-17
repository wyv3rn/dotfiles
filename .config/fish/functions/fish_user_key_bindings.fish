function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert

    bind -M insert \cf forward-bigword accept-autosuggestion
    bind -M insert \cb backward-bigword
    bind -M insert \cn beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \ch backward-kill-bigword
    bind -M insert \cg kill-bigword
end
