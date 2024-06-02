#!/usr/bin/env bash

generate_totp(){

  local path="${1%/}"
  local passfile="$PREFIX/$path.gpg"
  check_sneaky_paths "$path"

  if [[ -f $passfile ]]; then

    # Get "steam_secret:" line from gpg encrypted secret
    local key=$($GPG -d "${GPG_OPTS[@]}" "$passfile" | grep totp_secret | tr -d ' ' | cut -d':' -f2 | base32 -d | xxd -ps -c 256)

    # Divide current unix time by 30, convert to binary
    local time_seconds="$(printf '%.16x' $(($(date +%s)/30)))"

    if [[ ! -z "$key" ]]; then 

      # Compute HMAC-SHA1
      local hashcode=$(echo -n "$time_seconds" | xxd -r -p | openssl dgst -sha1 -mac HMAC -macopt hexkey:"$key" -binary | xxd -p -c 256)

      # Get starting position from last 4 bits
      local start=$((0x${hashcode:38:2} & 0xf))

      # Extract 4 bytes from start position
      local fc32_hex=${hashcode:$((start * 2)):8}
      local fc32=$((0x$fc32_hex & 0x7fffffff))

      if [ "${path:0:6}" = steam/ ]; then

        # Possible chars for auth code
        local chars="23456789BCDFGHJKMNPQRTVWXY"
        local chars_len=${#chars}

        # Generate auth code
        local code=""
        for i in {1..5}; do
          local index=$((fc32 % chars_len))
          code="${code}${chars:$index:1}"
          fc32=$((fc32 / chars_len))
        done

      else

        local code=$( printf "%06d" $((fc32 % 1000000)) )

      fi

      echo "$code"

    else
      die "Error: totp_secret: line not found inside $passfile"
    fi

  else
    die "Error: $passfile is not a valid path"
  fi

}

cmd_append_to_secret() {
  [[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND pass-name"

  local path="${1%/}"
  check_sneaky_paths "$path"
  mkdir -p -v "$PREFIX/$(dirname -- "$path")"
  set_gpg_recipients "$(dirname -- "$path")"
  local passfile="$PREFIX/$path.gpg"
  set_git "$passfile"

  tmpdir #Defines $SECURE_TMPDIR
  local tmp_file="$(mktemp -u "$SECURE_TMPDIR/XXXXXX")-${path//\//-}.txt"

  local action="Add"
  if [[ -f $passfile ]]; then
    $GPG -d -o "$tmp_file" "${GPG_OPTS[@]}" "$passfile" || exit 1
    action="Edit"
  fi
    ${EDITOR:-vi} "$tmp_file"
    [[ -f $tmp_file ]] || die "New password not saved."
    $GPG -d -o - "${GPG_OPTS[@]}" "$passfile" 2>/dev/null | diff - "$tmp_file" &>/dev/null && die "Password unchanged."
    while ! $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" "$tmp_file"; do
      yesno "GPG encryption failed. Would you like to try again?"
    done
    git_add_file "$passfile" "$action password for $path using ${EDITOR:-vi}."
}


# 
# Print TOTP
#

case "${2%/}" in
  -c|--clip) clip $(generate_totp "$@") ;;
  *) generate_totp "$@" ;;
esac
