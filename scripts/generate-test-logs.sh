#!/bin/bash
# generate-test-logs.sh
# SOC lab log generator for Linux auth logs
# Author: Edson Encinas
# Date: 2026-02-13

LOG_FILE="/var/log/auth.log"
ITERATIONS=10
DELAY=2  # seconds between log entries

echo "[*] Generating test logs in $LOG_FILE..."

for i in $(seq 1 $ITERATIONS); do
    TIMESTAMP=$(date "+%b %d %H:%M:%S")
    HOSTNAME=$(hostname)
    
    # Randomly choose success or failure
    if (( RANDOM % 2 )); then
        STATUS="Accepted password"
        USER="user$i"
        MSG="$TIMESTAMP $HOSTNAME sshd[100$i]: $STATUS for $USER from 192.168.1.$i port $((2000+i)) ssh2"
    else
        STATUS="Failed password"
        USER="user$i"
        MSG="$TIMESTAMP $HOSTNAME sshd[100$i]: $STATUS for $USER from 192.168.1.$i port $((2000+i)) ssh2"
    fi

    # Append to auth.log
    echo "$MSG" | sudo tee -a $LOG_FILE >/dev/null

    echo "[*] Generated log: $MSG"
    sleep $DELAY
done

echo "[*] Test log generation complete!"
