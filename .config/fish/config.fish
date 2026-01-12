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

# color theme
set --global fish_color_autosuggestion brblack
set --global fish_color_cancel -r
set --global fish_color_command blue
set --global fish_color_comment red
set --global fish_color_cwd green
set --global fish_color_cwd_root red
set --global fish_color_end green
set --global fish_color_error brred
set --global fish_color_escape brcyan
set --global fish_color_history_current --bold
set --global fish_color_host normal
set --global fish_color_host_remote yellow
set --global fish_color_normal normal
set --global fish_color_operator brcyan
set --global fish_color_param cyan
set --global fish_color_quote yellow
set --global fish_color_redirection cyan --bold
set --global fish_color_search_match white --background=brblack
set --global fish_color_selection white --bold --background=brblack
set --global fish_color_status red
set --global fish_color_user brgreen
set --global fish_color_valid_path --underline
set --global fish_pager_color_completion normal
set --global fish_pager_color_description yellow -i
set --global fish_pager_color_prefix normal --bold --underline
set --global fish_pager_color_progress brwhite --background=cyan
set --global fish_pager_color_selected_background -r
