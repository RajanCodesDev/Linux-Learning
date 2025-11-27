#!/bin/bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin   # ensures cron can find curl, sed, etc.

websites=(
"https://site1.com"
"https://site2.com"
"https://site3.com"
)

BOT_TOKEN="bot_token"
CHAT_ID="chat_id"

# File to store sites currently marked as down
DOWN_FILE="/tmp/sites_down.txt"

# Ensure DOWN_FILE exists
touch "$DOWN_FILE"

for site in "${websites[@]}"; do
    # Try up to 3 times if site is down
    retries=3
    success=false
    for ((i=1; i<=retries; i++)); do
        status=$(/usr/bin/curl -o /dev/null -s -w "%{http_code}" "$site")
        if [ "$status" -eq 200 ]; then
            success=true
            break
        fi
        sleep 2
    done

    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    if [ "$success" = false ]; then
        # If not already marked down → send alert once
        if ! grep -Fxq "$site" "$DOWN_FILE"; then
            /usr/bin/curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                 -d chat_id="$CHAT_ID" \
                 -d text="⚠️ [$timestamp] Site DOWN: $site (HTTP $status)"

            echo "$site" >> "$DOWN_FILE"
        fi
    else
        # If it was down before and now recovered → send recovery once
        if grep -Fxq "$site" "$DOWN_FILE"; then
            /usr/bin/curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
                 -d chat_id="$CHAT_ID" \
                 -d text="✅ [$timestamp] Site RECOVERED: $site (HTTP $status)"

            # Remove site from down file
            sed -i "\|$site|d" "$DOWN_FILE"
        fi
    fi
done
