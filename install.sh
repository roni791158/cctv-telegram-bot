#!/bin/sh

# Ask for user inputs
echo "Enter your RTSP URL:"
read RTSP_URL
echo "Enter your Telegram Bot Token:"
read BOT_TOKEN
echo "Enter your Telegram Channel ID (start with -100...):"
read CHANNEL_ID
echo "Enter video duration (seconds):"
read DURATION
echo "Enter how often to run the bot (in minutes):"
read INTERVAL

# Set environment variables
echo "RTSP_URL=$RTSP_URL" > /usr/bin/cctvbot/.env
echo "BOT_TOKEN=$BOT_TOKEN" >> /usr/bin/cctvbot/.env
echo "CHANNEL_ID=$CHANNEL_ID" >> /usr/bin/cctvbot/.env
echo "DURATION=$DURATION" >> /usr/bin/cctvbot/.env
echo "INTERVAL=$INTERVAL" >> /usr/bin/cctvbot/.env

# Download scripts
mkdir -p /usr/bin/cctvbot
wget -O /usr/bin/cctvbot/send_cctv.sh https://raw.githubusercontent.com/roni791158/cctv-telegram-bot/main/send_cctv.sh
wget -O /usr/bin/cctvbot/start.sh https://raw.githubusercontent.com/roni791158/cctv-telegram-bot/main/start.sh
wget -O /usr/bin/cctvbot/stop.sh https://raw.githubusercontent.com/roni791158/cctv-telegram-bot/main/stop.sh
wget -O /usr/bin/cctvbot/uninstall.sh https://raw.githubusercontent.com/roni791158/cctv-telegram-bot/main/uninstall.sh

# Set permissions
chmod +x /usr/bin/cctvbot/send_cctv.sh
chmod +x /usr/bin/cctvbot/start.sh
chmod +x /usr/bin/cctvbot/stop.sh
chmod +x /usr/bin/cctvbot/uninstall.sh

# Set up cron job
echo "*/$INTERVAL * * * * sh /usr/bin/cctvbot/send_cctv.sh" > /etc/crontabs/root

echo "✅ Done. Use:"
echo "sh /usr/bin/cctvbot/start.sh     # Start manually"
echo "sh /usr/bin/cctvbot/stop.sh      # Stop manually"
echo "sh /usr/bin/cctvbot/uninstall.sh # To uninstall"
