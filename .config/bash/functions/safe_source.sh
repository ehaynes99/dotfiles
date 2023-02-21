safe_source() {
	file="$1"
	if [[ ! "$file" =~ ^/ ]]; then
		file="$BASH_CONFIG_DIR/$file"
	fi

	if [[ -f "$file" ]]; then
		# shellcheck disable=1090
		source "$file"
	else
		echo "attempt to source non-existent file: ${file}"
	fi
}
