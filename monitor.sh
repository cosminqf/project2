#!/bin/bash

WORK_DIR="./data"
# for cron use: specify whole path
# WORK_DIR="/home/ubuntu/ITBI/Work/data"

LAST_PROCESSED="$WORK_DIR/last_processed.log"
DPKG_LOG="/var/log/dpkg.log"

mkdir -p "$WORK_DIR"

if [ ! -f "$LAST_PROCESSED" ]; then
    echo "1970-01-01 00:00:00" >"$LAST_PROCESSED"
fi

LAST_DATE=$(cat "$LAST_PROCESSED")

awk -v last_date="$LAST_DATE" '$1 " " $2 > last_date' "$DPKG_LOG" | grep -E "( install | remove )" | while read -r line; do
    DATE=$(echo "$line" | awk '{print $1}')
    TIME=$(echo "$line" | awk '{print $2}')
    ACTION=$(echo "$line" | awk '{print $3}')

    PACKAGE=$(echo "$line" | awk '{print $4}' | cut -d':' -f1)

    if [ -n "$PACKAGE" ]; then
        PACKAGE_DIR="$WORK_DIR/$PACKAGE"
        mkdir -p "$PACKAGE_DIR"

        echo "$DATE $TIME $ACTION" >>"$PACKAGE_DIR/history.log"
    fi
done

tail -n 1 "$DPKG_LOG" | awk '{print $1 " " $2}' >"$LAST_PROCESSED"

echo "Monitor actualizat."
