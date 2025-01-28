#!/usr/bin/env nu

def main [] {
	# NB: if you `swaymsg output XYZ disable`, you'll still have a display entry, it
	# just won't be active
	let options = swaymsg -t get_outputs | from json | where active | select name model | each {|e|
		match $e.model {
			'LG ULTRAGEAR' => {display: 'main', id: $e.name},
			'P2718EC' => {display: 'vertical', id: $e.name},
			_ if ($e.name | str starts-with 'eDP-') => {display: 'builtin', id: $e.name},
			_ => {display: $e.model, id: $e.name}
		}
	}

	let choice_raw = ($options | get display | str join "\n" | tofi --prompt-text "move workspace to ")

	let choice = $options | where display == $choice_raw | get 0?.id

	if $choice != null {
		swaymsg move workspace to output $choice
	}
}
