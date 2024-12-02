#!/usr/bin/env nu

def main [raw: string] {
	let parsed = $raw | 
		url parse |
		select path host fragment |
		rename path host section |
		insert ident {|$i| if $i.path == "" { $i.host } else { $i.path } } |
		select ident section |
		update ident {|$i| if ($i.ident | str starts-with 'draft-') { $i.ident } else { $"rfc($i.ident)" } }

	if $parsed.section == "" {
		xdg-open $"https://datatracker.ietf.org/doc/html/($parsed.ident)"
	} else {
		xdg-open $"https://datatracker.ietf.org/doc/html/($parsed.ident)#section-($parsed.section)"
	}
}
