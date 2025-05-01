#!/bin/sh

# Load environment variables
source /usr/bin/cctvbot/.env

# Record video from RTSP stream
ffmpeg -i "$RTSP_URL" -t "$DURATION" -vcodec copy /tmp/video.mp4

# Send the video to Telegram channel
curl -F video="@/tmp/video.mp4" "https://api.telegram.org/bot$BOT_TOKEN/sendVideo?chat_id=$CHANNEL_ID"

# Clean up video file
rm /tmp/video.mp4
