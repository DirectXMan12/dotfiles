{ config, pkgs, jj, ... }:

pkgs.stdenvNoCC.mkDerivation {
	pname = "jj-nushell-completions";
	version = jj.version;

	src = null;
	
	dontUnpack = true;

	# T_T dynamic nushell completions aren't merged yet
	# see
	# - https://github.com/jj-vcs/jj/compare/main...chklauser:jj:push-rppypvvytuqv
	# - https://github.com/clap-rs/clap/issues/5840
	#
	# for some reason clap seems to have a hard required on auto-updating, which
	# is... questionable
	#
	# in the mean time, static completions it is
	buildPhase = ''
		${pkgs.lib.getExe jj} util completion nushell > jj-completions.nu
	'';

	installPhase = ''
		mv jj-completions.nu $out
	'';
}
