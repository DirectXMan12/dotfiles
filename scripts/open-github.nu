#!/usr/bin/env nu

def main [raw: string] {
	let parsed = $raw | 
		url parse |
		select path fragment |
		rename path issue | 
		update path {|$i| $i.path | parse "{owner}/{repo}" | get 0 } |
		flatten |
		get 0

	if parsed.issue == null {
		xdg-open $"https://github.com/($parsed.owner)/($parsed.repo)/"
	} else {
		xdg-open $"https://github.com/($parsed.owner)/($parsed.repo)/issues/($parsed.issue)"
	}
}
