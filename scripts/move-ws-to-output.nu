#!/usr/bin/env nu

def main [] {
	let options = swaymsg -t get_outputs | from json | select id name model | each {|e|
		match $e.model {
			'LG ULTRAGEAR' => {display: 'main', id: $e.name},
			'P2718EC' => {display: 'vertical', id: $e.name},
			_ if $e.name == 'eDP-1' => {display: 'builtin', id: $e.name},
			_ => {display: $e.model, id: $e.name}
		}
	}

	let choice_raw = ($options | get display | str join "\n" | tofi --prompt-text "move workspace to ")

	let choice = $options | where display == $choice_raw | get 0.id

	swaymsg move workspace to output $choice
}
