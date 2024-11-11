#!/usr/bin/env nu

def main [raw: string] {
	let parsed = $raw | 
		url parse |
		select path fragment |
		rename number section

	if parsed.section == null {
		xdg-open $"https://datatracker.ietf.org/doc/html/rfc($parsed.number)"
	} else {
		xdg-open $"https://datatracker.ietf.org/doc/html/rfc($parsed.number)#section-($parsed.section)"
	}
}
