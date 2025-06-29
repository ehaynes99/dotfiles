#!/usr/bin/env bash

load_env() {
	if [[ -f "$1" ]]; then
		while IFS= read -r line; do
			[[ $line =~ ^[[:space:]]*# ]] &&
				continue
			[[ -z $line ]] && continue
			eval "export $line"
		done <"$1"
	fi
}
