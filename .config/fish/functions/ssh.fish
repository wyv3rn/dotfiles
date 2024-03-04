function ssh --description 'Evaluate keychain before ssh'
    if type -q keychain
        keychain --ignore-missing --eval id_rsa id_ed25519 | source
    end
    command ssh $argv
end
