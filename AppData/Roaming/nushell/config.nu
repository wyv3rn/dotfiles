$env.config = {
    buffer_editor: nvim,
    shell_integration: {
        osc133: false
    }
}

alias l = ls
alias v = nvim
alias dotf = git --git-dir=($env.HOMEPATH)/.dotfiles.git/ --work-tree=($env.HOMEPATH)
alias sdotf = git --git-dir=($env.HOMEPATH)/.sdotfiles.git/ --work-tree=($env.HOMEPATH)
