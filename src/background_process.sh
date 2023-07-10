#!/bin/bash
applications=()
    for win_id in $( wmctrl -l | cut -d' ' -f1 );
    do
        if  $( xprop -id $win_id _NET_WM_WINDOW_TYPE | grep -q _NET_WM_WINDOW_TYPE_NORMAL ) ; then
            appname=$( xprop -id $win_id WM_CLASS | cut -d" " -f4 )
            appname=${appname#?}
            appname=${appname%?}
            applications+=( "$appname" )
        fi
    done
    readarray -t applications < <(printf '%s\0' "${applications[@]}" | sort -z | xargs -0n1 | uniq)
    printf -- '%s\n' "${applications[@]}"
