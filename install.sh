#!/bin/sh

INSTALL_DIR="/usr/bin/cctvbot"
CONFIG_FILE="$INSTALL_DIR/config.ini"
PID_FILE="/tmp/cctvbot.pid"

mkdir -p "$INSTALL_DIR"

echo "Enter your RTSP URL:"
read RTSP_URL

echo "Enter your Telegram Bot Token:"
read BOT_TOKEN

echo "Enter your Telegram Channel ID (start with -100...):"
read CHAT_ID

echo "Enter video duration (seconds):"
read DURATION

echo "Enter how often to run the bot (in minutes):"
read INTERVAL

cat <<EOF > $CONFIG_FILE
rtsp_url=$RTSP_URL
bot_token=$BOT_TOKEN
chat_id=$CHAT_ID
duration=$DURATION
interval=$INTERVAL
EOF

cat <<'EOF' > "$INSTALL_DIR/send_cctv.sh"
#!/bin/sh
CONFIG_FILE="/usr/bin/cctvbot/config.ini"
. "$CONFIG_FILE"

FILE="/tmp/cctv_clip.mp4"

ffmpeg -rtsp_transport tcp -i "$rtsp_url" -t "$duration" -vcodec copy -an "$FILE"

curl -s -X POST "https://api.telegram.org/bot$bot_token/sendVideo" \
  -F chat_id="$chat_id" \
  -F video=@"$FILE" \
  -F caption="CCTV Clip"
EOF

chmod +x "$INSTALL_DIR/send_cctv.sh"

cat <<'EOF' > "$INSTALL_DIR/start.sh"
#!/bin/sh
sh /usr/bin/cctvbot/send_cctv.sh &
echo $! > /tmp/cctvbot.pid
echo "✅ CCTV Bot started manually."
EOF

cat <<'EOF' > "$INSTALL_DIR/stop.sh"
#!/bin/sh
[ -f /tmp/cctvbot.pid ] && kill "$(cat /tmp/cctvbot.pid)" && rm /tmp/cctvbot.pid && echo "🛑 CCTV Bot stopped." || echo "⚠️ Not running."
EOF

cat <<'EOF' > "$INSTALL_DIR/uninstall.sh"
#!/bin/sh
sed -i '/send_cctv.sh/d' /etc/crontabs/root
rm -rf /usr/bin/cctvbot
echo "🗑️ CCTV Bot removed."
EOF

chmod +x "$INSTALL_DIR/"*.sh

sed -i '/send_cctv.sh/d' /etc/crontabs/root
echo "*/$INTERVAL * * * * sh $INSTALL_DIR/send_cctv.sh" >> /etc/crontabs/root
/etc/init.d/cron restart

opkg update && opkg install ffmpeg curl

echo "✅ Done. Use:"
echo "  sh $INSTALL_DIR/start.sh     # Start manually"
echo "  sh $INSTALL_DIR/stop.sh      # Stop manually"
echo "  sh $INSTALL_DIR/uninstall.sh # To uninstall"
