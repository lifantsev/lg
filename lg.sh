LGPATH="$XDG_STATE_HOME/logs"
mkdir -p "$LGPATH"

# read args
arg_action=""
arg_logname=""

function read_logname() {
    if [ -n "${1:-}" ]; then
        arg_logname="$1"
    else
        echo "lg error: action[$arg_action] expects a log name to act on but none was provided" >> /dev/stderr
        exit 1
    fi
}

case "${1:-}" in
    "view"|"v")  arg_action="view"  ; read_logname "${2:-}" ;;
    "tail"|"t")  arg_action="tail"  ; read_logname "${2:-}" ;;
    "watch"|"w") arg_action="watch" ; read_logname "${2:-}" ;;
    "clear"|"c") arg_action="clear" ; read_logname "${2:-}" ;;
    *) arg_action="view" ; read_logname "${1:-}" ;;
esac

logpath="$LGPATH/$arg_logname.log"

if [[ "$arg_action" == "clear" ]] && [[ "$arg_logname" == "all" ]]; then
    true
else
    if ! [[ -f "$logpath" ]]; then
        echo "lg error: specified logfile[$logpath] does not exist"
        exit 1
    fi
fi

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
