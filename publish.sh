#!/bin/sh

set -e

######################################## util #########################################

COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;94m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

run() {
    printf '%b\n' "${COLOR_PURPLE}==>${COLOR_OFF} ${COLOR_GREEN}$*${COLOR_OFF}"
    eval "$*"
}

die() {
    printf '%b\n' "${COLOR_RED}💔  $*${COLOR_OFF}" >&2
    exit 1
}

die_if_command_not_found() {
    for item in $@
    do
        command -v $item > /dev/null || die "$item command not found."
    done
}

sed_in_place() {
    if command -v gsed > /dev/null ; then
        unset SED_IN_PLACE_ACTION
        SED_IN_PLACE_ACTION="$1"
        shift
        # contains ' but not contains \'
        if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
            run gsed -i "\"$SED_IN_PLACE_ACTION\"" $@
        else
            run gsed -i "'$SED_IN_PLACE_ACTION'" $@
        fi
    elif command -v sed  > /dev/null ; then
        if sed -i 's/a/b/g' $(mktemp) 2> /dev/null ; then
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i "'$SED_IN_PLACE_ACTION'" $@
            fi
        else
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i '""' "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i '""' "'$SED_IN_PLACE_ACTION'" $@
            fi
        fi
    else
        error "please install sed utility."
        return 1
    fi
}

######################################## main #########################################

die_if_command_not_found tar gzip xz gh sed grep hexdump date sha256sum

run cd "$(dirname "$0")"

run pwd


unset RELEASE_VERSION

RELEASE_VERSION="$(date +%Y.%m.%d)"
RELEASE_NOTES_FILE='release-notes.md'

cat > "$RELEASE_NOTES_FILE" <<EOF
|sha256sum|filename|
|---------|--------|
EOF

for filename in $(cd package && ls *.tar.xz)
do
    unset PACKAGE_BIN_SHA
    PACKAGE_BIN_SHA=$(sha256sum "package/$filename" | cut -d ' ' -f1)
    printf '|%s|%s|\n' "$PACKAGE_BIN_SHA" "$filename" >> "$RELEASE_NOTES_FILE"
done

run gh release create "$RELEASE_VERSION" package/*.tar.xz --notes-file "$RELEASE_NOTES_FILE"
