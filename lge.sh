[ -z "${1:-}" ] && exit

lga E "$1"

prefix=""
[ -n "${LGSPEC:-}" ] && prefix="$LGSPEC: "
echo "$LGSTEM ${prefix}error: $1"
