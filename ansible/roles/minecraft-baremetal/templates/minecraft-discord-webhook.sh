#!/bin/bash
# {{ ansible_managed }}

#############################################
# CONFIG
#############################################

WEBHOOK_URL=$(cat /home/$(whoami)/.minecraft-webhook-url.txt)
SERVERLOG="/opt/minecraft/grass-gang/logs/latest.log"
BOTNAME="Minecraft"
AVATAR="https://www.minecraft.net/etc.clientlibs/minecraft/clientlibs/main/resources/android-icon-192x192.png"
CACHE=$(date +'%Y%m%d')

if [[ ! -f "$SERVERLOG" ]]; then
    echo "Error: Log file $SERVERLOG not found."
    exit 1
fi

#############################################
# WEBHOOK FUNCTION
#############################################

send_webhook() {
    local message="$1"
    local color="$2"
    local icon="$3"

    curl -s -H "Content-Type: application/json" \
        -X POST \
        -d "{
            \"username\": \"$BOTNAME\",
            \"avatar_url\": \"$AVATAR\",
            \"embeds\": [{
                \"color\": $color,
                \"author\": {\"name\": \"$message\", \"icon_url\": \"$icon\"}
            }]
        }" "$WEBHOOK_URL" > /dev/null
}

#############################################
# PATTERNS
#############################################

# Compatible with:
#  - Vanilla
#  - Paper
#  - Purpur
#  - Spigot
# Example formats:
# [12:09:00 INFO]: Player joined the game
# [Server thread/INFO]: Player joined the game

regex_join='INFO\]: ([A-Za-z0-9_]+) joined the game'
regex_leave='INFO\]: ([A-Za-z0-9_]+) left the game'
regex_chat='INFO\]: <([A-Za-z0-9_]+)> (.*)'
regex_advancement='INFO\]: ([A-Za-z0-9_]+) has (made the advancement|completed the challenge|reached the goal) (.*)'
regex_command='INFO\]: ([A-Za-z0-9_]+) issued server command: (.*)'
regex_death='INFO\]: ([A-Za-z0-9_]+) (fell from a high place|.* died.*|.* was .*|.* hit .*|.* drowned.*|.* suffocated.*|.* blew up.*|.* fell .*|.* burnt.*)'

# Optional: Geyser
regex_geyser='Geyser.*INFO.*\]: (.*)'

#############################################
# STARTUP NOTICE
#############################################

send_webhook "Discord webhook monitor active." 9737364 "$AVATAR"

#############################################
# SERVER HEALTH CHECK (Runs in background)
#############################################

server_down_notified=false

check_server_health() {
    while true; do
        # Detect if a Paper/Vanilla Java server is running
        if pgrep -f "paper-.*\.jar" > /dev/null || pgrep -f "minecraft" > /dev/null; then
            if [[ "$server_down_notified" == true ]]; then
                send_webhook "🟢 Minecraft server is back online." 3066993 "$AVATAR"
                server_down_notified=false
            fi
        else
            if [[ "$server_down_notified" == false ]]; then
                send_webhook "🔴 Minecraft server has stopped or crashed!" 15158332 "$AVATAR"
                server_down_notified=true
            fi
        fi

        sleep 5
    done
}

# Run in background
check_server_health & disown


#############################################
# MAIN LOOP
#############################################

tail -n 0 -F "$SERVERLOG" | while read -r line; do

    # JOIN
    if [[ $line =~ $regex_join ]]; then
        player="${BASH_REMATCH[1]}"
        send_webhook "$player joined the game" 65280 "https://minotar.net/helm/$player?v=$CACHE"
        continue
    fi

    # LEAVE
    if [[ $line =~ $regex_leave ]]; then
        player="${BASH_REMATCH[1]}"
        send_webhook "$player left the game" 16753920 "https://minotar.net/helm/$player?v=$CACHE"
        continue
    fi

    # CHAT
    if [[ $line =~ $regex_chat ]]; then
        player="${BASH_REMATCH[1]}"
        message="${BASH_REMATCH[2]}"
        send_webhook "<$player> $message" 33023 "https://minotar.net/helm/$player?v=$CACHE"
        continue
    fi

    # ADVANCEMENT
    if [[ $line =~ $regex_advancement ]]; then
        player="${BASH_REMATCH[1]}"
        achievement="${BASH_REMATCH[3]}"
        send_webhook "$player earned $achievement" 3447003 "https://minotar.net/helm/$player?v=$CACHE"
        continue
    fi

    # COMMANDS
    if [[ $line =~ $regex_command ]]; then
        player="${BASH_REMATCH[1]}"
        command="${BASH_REMATCH[2]}"
        send_webhook "$player executed command: $command" 16776960 "https://minotar.net/helm/$player?v=$CACHE"
        continue
    fi

     # DEATHS
     if [[ $line =~ $regex_death ]]; then
         player="${BASH_REMATCH[1]}"
         deathmsg="${player} ${BASH_REMATCH[2]}"
         send_webhook "$deathmsg" 16711680 "https://minotar.net/helm/$player?v=$CACHE"
         continue
    fi

    # GEYSER INFO
    if [[ $line =~ $regex_geyser ]]; then
        message="${BASH_REMATCH[1]}"
        send_webhook "$message" 3447003 "https://geysermc.org/img/icons/geyser.png"
        continue
    fi

done
