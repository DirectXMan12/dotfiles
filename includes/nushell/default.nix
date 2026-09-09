{ config, pkgs, lib, ... }:

let
  # TODO: need to patch home-manager to just... do this
  toNushell = lib.hm.nushell.toNushell {};
  # there's probably a better way to do this, but XDG_DATA_DIRS usually
  # has some shell substitution in it, which nu can't interpret as written,
  # so skip that.
  # TODO: update home-manager to make this work.
  replace-if-missing-patterns = raw: (
    let
      pattern = "[$][{]([^:]+):-([^}]+)[}]";
      split = builtins.split pattern raw;
      repaired = builtins.map (item: if builtins.isList item then ''($env.${builtins.elemAt item 0}? | default ${toNushell (builtins.elemAt item 1)})'' else toNushell item) split;
      joined = builtins.concatStringsSep " + " repaired;
      as-subst = "(${joined})";
    in
      if builtins.match ".*${pattern}.*" raw != null then as-subst else toNushell raw
  );
  # sadly, XDG_DATA_DIRS looks like a search path, but just has the pattern
  # hardcoded instead, with a slightly different pattern
  replace-prepend-pattern = name: pkgs.lib.replaceString "\${${name}:+:\$${name}}" "";
  fix-session-var = name: val: replace-if-missing-patterns (replace-prepend-pattern name val);
  session-vars = ''
    if not ($env.__HM_NU_SESS_VARS_SOURCED? | default false) {
      load-env {
        ${builtins.concatStringsSep "\n  " (pkgs.lib.mapAttrsToList (name: val:
          ''${toNushell name}: ${if builtins.isString val then (fix-session-var name val) else toNushell val}''
        ) config.home.sessionVariables)}
      }
      ${builtins.concatStringsSep "\n  " (pkgs.lib.mapAttrsToList (name: val:
        ''
          $env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
            ${toNushell name}: {
              from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
              to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
            }
          }
          $env.${toNushell name} ++= [
            ${builtins.concatStringsSep "\n  " (builtins.map (item: replace-if-missing-patterns item) val)}
          ]
        ''
      ) config.home.sessionSearchVariables)}
      $env.__HM_NU_SESS_VARS_SOURCED = true
    }
  '';
in
{
  programs.nushell = {
    enable = true;
    # equivalent of sourcing hm-session-vars, minus any extras
    # TODO: we should probably assert for empty extras
    environmentVariables = {
      SHELL = pkgs.lib.getExe config.programs.nushell.package;
    };
    configFile.text = ''
      ${session-vars}
      # for light-mode and dark-mode
      let alacritty_themes: record<light: path, dark: path> = {
        light: "${../alacritty/solarized-light.toml}",
        dark: "${../alacritty/solarized-dark-custom.toml}"
      }
    '' + builtins.readFile ./config.nu;
    settings = {
      buffer_editor = "${pkgs.lib.getExe config.programs.neovim.package}";
      show_banner = false;
    };
  };
}
