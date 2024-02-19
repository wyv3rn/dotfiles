bind \cf forward-bigword accept-autosuggestion
bind \cb backward-bigword
bind \cn beginning-of-line
bind \ce end-of-line
bind \ch backward-kill-bigword
bind \cg kill-bigword

if status is-interactive
end

if type -q zoxide
    zoxide init fish --cmd cd | source
end