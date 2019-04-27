#!/usr/bin/env bash

mail=${HOME}/mail
fzf_command='fzf'
fd_command="fd . ${mail} --type d -E cur -E tmp -E new"

folder="$($fd_command | $fzf_command)"

echo "push ':exec change-folder<enter>$folder<enter>'"
