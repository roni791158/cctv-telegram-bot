#!/bin/sh

# Remove cron job
sed -i '/cctvbot\/send_cctv.sh/d' /etc/crontabs/root

# Remove files
rm -rf /usr/bin/cctvbot

# Stop cron job
/etc/init.d/cron stop

echo "Uninstallation complete!"
