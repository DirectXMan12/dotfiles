def main [prompt: string = "ssh passphrase/pin for yubikey (ssh-agent gave no prompt)"] {
  exec tofi --prompt $"($prompt): " --require-match=false --hide-input=true
}
