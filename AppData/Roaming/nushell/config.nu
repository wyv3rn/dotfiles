$env.config = {
    buffer_editor: nvim,
    shell_integration: {
        osc133: false
    }
}

$env.config.edit_mode = 'vi'
$env.config.cursor_shape = {
  vi_insert: line
  vi_normal: block
}

$env.config.keybindings ++= [
  {
    name: move_right_or_take_history_hint
    modifier: control
    keycode: char_f
    mode: [emacs, vi_insert, vi_normal]
    event: {
      until: [
        {send: historyhintcomplete}
        {send: menuright}
        {send: right}
      ]
    }
  }
  {
    name: cut_line_from_start
    modifier: control
    keycode: char_u
    mode: [emacs, vi_insert, vi_normal]
    event: {edit: cutfromstart}
  }
]

alias l = ls
alias v = nvim
alias cat = open
alias dotf = git --git-dir=($env.HOMEPATH)/.dotfiles.git/ --work-tree=($env.HOMEPATH)
alias sdotf = git --git-dir=($env.HOMEPATH)/.sdotfiles.git/ --work-tree=($env.HOMEPATH)
