decode_jwt() {
  if [ "$1" = "" ]; then
    echo "usage: decode_jwt <string>"
    return 1
  fi
  jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "$1"
}
