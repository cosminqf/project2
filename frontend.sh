#!/bin/bash

WORK_DIR="./data"

list_installed() {
    echo "Pachete instalate si data ultimei instalari:"

    for pkg in "$WORK_DIR"/*; do
        if [ -d "$pkg" ]; then
            LAST_ACTION=$(tail -n 1 "$pkg/history.log" | awk '{print $3}')

            if [ "$LAST_ACTION" == "install" ]; then
                LAST_INSTALL=$(grep "install" "$pkg/history.log" | tail -n 1)
                echo "$(basename "$pkg") - $LAST_INSTALL"
            fi
        fi
    done
}

list_removed() {
    echo "Pachete eliminate si data ultimei inlaturari:"

    for pkg in "$WORK_DIR"/*; do
        if [ -d "$pkg" ]; then
            if grep -q "remove" "$pkg/history.log"; then
                LAST_REMOVE=$(grep "remove" "$pkg/history.log" | tail -n 1)
                echo "$(basename "$pkg") - $LAST_REMOVE"
            fi
        fi
    done
}

package_history() {
    if [ -z "$1" ]; then
        echo "Eroare: Trebuie sa specifici un pachet."
        return
    fi

    if [ -f "$WORK_DIR/$1/history.log" ]; then
        echo "Istoria operatiunilor pentru pachetul $1:"
        cat "$WORK_DIR/$1/history.log"
    else
        echo "Pachetul $1 nu are un istoric inregistrat."
    fi
}

list_in_timeframe() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Eroare: Trebuie sa specifici intervalul de timp (YYYY-MM-DD)."
        return
    fi

    echo "Pachete instalate/eliminate intre $1 si $2:"

    for pkg in "$WORK_DIR"/*; do
        # verifica daca e fisier
        if [ -d "$pkg" ]; then

            if [ -f "$pkg/history.log" ]; then
                awk -v start="$1" -v end="$2" '$1 >= start && $1 <= end' "$pkg/history.log" | while read -r line; do
                    echo "$(basename "$pkg") - $line"
                done
            fi
        fi
    done
}

case $1 in
list-installed)
    list_installed
    ;;
list-removed)
    list_removed
    ;;
history)
    package_history "$2"
    ;;
list-timeframe)
    list_in_timeframe "$2" "$3"
    ;;
*)
    echo "Utilizare: $0 {list-installed|list-removed|history <pachet>|list-timeframe <start> <end>}"
    ;;
esac
