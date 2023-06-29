#/usr/bin/env zsh

url=${1:?must specify a term-at:// url}
target=${url#term-at://}
swaymsg exec '$term'" --working-directory '${target:?must specify a target directory}'"
