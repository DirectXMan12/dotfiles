$env.PROMPT_COMMAND = {||
  let dir = match (do -i { $env.PWD | path relative-to $nu.home-dir }) {
    null => $env.PWD
    '' => '~'
    $relative_pwd => ([~ $relative_pwd] | path join)
  }

  let location = match ($env.COMPUTER_LOCATION? | default (sys host | hostname)) {
    null => $"(ansi bold_yellow){unknown computer}(ansi reset)",
    'yasamin' => '💻'
    $otherwise => $otherwise,
  }

  let user_part = match (whoami) {
    'directxman12' => ''
    $otherwise => $"($otherwise)@",
  }

  let colors: record<path: string, separator: string, user: string> = match [(config use-colors), (is-admin)] {
    [false, _] => {user: '', path: '', separator: ''}
    [true, true] => {user: (ansi red_bold), path: (ansi magenta_bold), separator: (ansi light_magenta_bold)}
    # green is gray in solarized, so use an actual greenish
    [true, false] => {user: (ansi {fg: gold3a, attr: bold}), path: (ansi magenta_bold), separator: (ansi light_magenta_bold)}
  }

  let path_segment = $"($colors.path)($dir)(ansi reset)"

  let colored_path = $path_segment | str replace --all (char path_sep) $"($colors.separator)(char path_sep)($colors.path)"

  $"($colors.user)($user_part)($location)(ansi reset) ($"term-at://($dir)" | ansi link --text $colored_path)"
}

$env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
  "XDG_DATA_DIRS": {
    from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
    to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
  }
}

$env.PROMPT_COMMAND_RIGHT = {||}

def term-at [location?: path] {
  # NB: $term is a sway var, not a nushell one
  swaymsg exec $"$term --working-directory ($location)"
}

def light-mode [] {
  noctalia msg theme-mode-set light
}

def dark-mode [] {
  noctalia msg theme-mode-set dark
}

alias fg = job unfreeze
