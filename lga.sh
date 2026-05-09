{
    [ -z "${LGSTEM:-}" ] && exit # exit if no stem is specified
    [ -z "${LGENABLE:-}" ] && LGENABLE=0
    (( ! LGENABLE )) && exit # immediately exit if logging is disabled

    LGPATH="$XDG_STATE_HOME/logs"
    mkdir -p "$LGPATH"

    loglevel="$1"
    logstr="${2:-}" 

    logpath="$LGPATH/$LGSTEM.log"

    prefix=""
    [ -n "${LGSPEC:-}" ] && prefix="$LGSPEC: "

    flock 9

    if [[ "$loglevel" == "start" ]]; then
        echo "${prefix}start $(date +"%S.%3N")" >> "$logpath" 2>/dev/null
        exit
    fi

    if [[ "$loglevel" == "finish" ]]; then
        tstart="$(cat "$logpath" | grep "^${prefix}start " | sed "s|^${prefix}start ||" | tail -n 1)"
        tfin="$(cat "$logpath" | grep -v "^${prefix}start \|^${prefix}finish " | tail -n 1 | awk '{ print $4 }')"
        diff="$(echo "$tfin - $tstart" | bc)"
        echo "${prefix}finish $diff" >> "$logpath" 2>/dev/null
        echo >> "$logpath" 2>/dev/null
        exit
    fi

    if [[ "$logstr" == "-" ]]; then logstr="$(cat)"; fi
    [[ -z "$logstr" ]] && exit 0

    echo "$loglevel $(date +"%H:%M @ %S.%3N") $loglevel $prefix$logstr" >> "$logpath" 2>/dev/null

} 9>/tmp/lga.lock &>/dev/null &
