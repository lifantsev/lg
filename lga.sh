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

    col_def="\033[0m"
    col_red="\033[0;31m"
    col_green="\033[0;32m"
    col_yellow="\033[0;33m"
    col_blue="\033[0;34m"
    col_purple="\033[0;35m"

    flock 9 # wait for lockfile to be released, then grab it

    if [[ "$loglevel" == "start" ]]; then
        printf "$col_purple" >> "$logpath"
        echo "${prefix}start $(date +"%S.%3N")" >> "$logpath" 2>/dev/null
        printf "$col_def" >> "$logpath"

        exit
    fi

    if [[ "$loglevel" == "finish" ]]; then
        tstart="$(cat "$logpath" | grep "^${prefix}start " | sed "s|^${prefix}start ||" | tail -n 1)"
        n2="[0-9][0-9]"
        tfin="$(cat "$logpath" | grep -v "^${prefix}start \|^${prefix}finish " | grep "$n2:$n2 @ $n2\.${n2}[0-9]" | tail -n 1 | awk '{ print $4 }')"
        diff="$(echo "$tfin - $tstart" | bc)"

        printf "$col_purple" >> "$logpath"
        echo "${prefix}finish $diff" >> "$logpath" 2>/dev/null
        printf "$col_def" >> "$logpath"

        echo >> "$logpath" 2>/dev/null

        exit
    fi

    if [[ "$logstr" == "-" ]]; then logstr="$(cat)"; fi
    [[ -z "$logstr" ]] && exit 0

    case "$loglevel" in
        E) printf "$col_red"    >> "$logpath" ;; # error
        R) printf "$col_green"  >> "$logpath" ;; # return
        I) printf "$col_yellow" >> "$logpath" ;; # info
        F) printf "$col_blue"   >> "$logpath" ;; # function
    esac

    echo "$loglevel $(date +"%H:%M @ %S.%3N") $loglevel $prefix$logstr" >> "$logpath" 2>/dev/null

    printf "$col_def" >> "$logpath"

} 9>/tmp/lga.lock &>/dev/null &
