def --wrapped "main" [-e ...args] {
  if (($args | slice 0..1) == ["sh" "-lc"]) and ($args.2 | str starts-with "swaymsg exec --") {
    let cmd = ($args.2 | str replace -r "^swaymsg exec -- " "")
    let args = [$cmd, ...($args | slice 3..)]
    swaymsg exec -- '$term' -e ...$args
  }
}
