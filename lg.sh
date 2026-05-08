LGPATH="$XDG_STATE_HOME/logs"
mkdir -p "$LGPATH"

# read args
arg_action=""
arg_logname=""

arg_loglevel=""
arg_logstr=""

function read_logname() {
    if [ -n "${1:-}" ]; then
        arg_logname="$1"
    else
        echo "lg error: action[$arg_action] or loglevel[$arg_loglevel] expects a log name to act on but none was provided" >> /dev/stderr
        exit 1
    fi
}

function read_logstr() {
    case "$arg_loglevel" in
        "start"|"finish") return ;;
        *) if [ -z "${1:-}" ]; then
            echo "lg_error: loglevel[$arg_loglevel] requires a logstr but none was passed"
            exit 1
        else
            arg_logstr="$1"
        fi
        ;;
    esac
}

case "$1" in
    "view"|"v")  arg_action="view"  ; read_logname "${2:-}" ;;
    "tail"|"t")  arg_action="tail"  ; read_logname "${2:-}" ;;
    "watch"|"w") arg_action="watch" ; read_logname "${2:-}" ;;
    "clear"|"c") arg_action="clear" ; read_logname "${2:-}" ;;
    *) 
        [ -z "${LGENABLE:-}" ] && LGENABLE=0
        (( ! LGENABLE )) && exit 0 # immediately exit if logging is disabled
        arg_loglevel="$1" ; read_logstr "${2:-}" ; read_logname "${LGSTEM:-}";;
esac

logpath="$LGPATH/$arg_logname.log"

function check_logname() {
    if [[ "$arg_action" == "clear" ]] && [[ "$arg_logname" == "all" ]]; then
        return
    else
        if ! [[ -f "$logpath" ]]; then
            if [[ -n "$arg_action" ]]; then
                echo "lg error: specified logfile[$logpath] does not exist"
                exit 1
            else
                echo -n > "$logpath"
            fi
        fi
    fi
}
check_logname

if [ -n "$arg_action" ]; then
    case "$arg_action" in
        "view") less "$logpath" ;;
        "tail") tail -n 20 "$logpath" ;;
        "watch") watch -n 0.5 tail -n 50 "$logpath" ;;
        "clear") 
            if [[ "$arg_logname" == "all" ]]; then
                for logfile in "$LGPATH/"*; do echo -n > "$logfile"; done
            else
                echo -n > "$logpath"
            fi
            ;;
    esac
    exit 0
fi

prefix=""
[ -n "${LGSPEC:-}" ] && prefix="$LGSPEC: "

case "$arg_loglevel" in
    "start")
        echo "${prefix}start $(date +"%S.%3N")" >> "$logpath" 2>/dev/null
        ;;
    "finish")
        tstart="$(cat "$logpath" | grep "^${prefix}start " | sed "s|^${prefix}start ||" | tail -n 1)"
        tfin="$(cat "$logpath" | grep -v "^${prefix}start \|^${prefix}finish " | tail -n 1 | awk '{ print $4 }')"
        diff="$(echo "$tfin - $tstart" | bc)"
        echo "${prefix}finish $diff" >> "$logpath" 2>/dev/null
        echo >> "$logpath" 2>/dev/null
        ;;
    *)
        if [[ "$arg_logstr" == "-" ]]; then arg_logstr="$(cat)"; fi
        [[ -z "$arg_logstr" ]] && exit 0

        echo "$arg_loglevel $(date +"%H:%M @ %S.%3N") $arg_loglevel $prefix$arg_logstr" >> "$logpath" 2>/dev/null
        [ "$arg_loglevel" == E ] && echo "$arg_logname ${prefix}error: $arg_logstr"
        ;;
esac

exit 0
