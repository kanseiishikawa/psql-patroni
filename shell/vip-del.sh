#!/bin/bash
VIP="172.20.0.100/24"
INTERFACE="eth0"

VIP_IP="${VIP%/*}"
LOG_FILE="/var/log/patroni_vip.log"

# VIPが存在する場合のみ削除処理を実行
if ip addr show dev "$INTERFACE" | grep -q "${VIP_IP}/"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VIP-DEL] Removing VIP $VIP from $INTERFACE" >> "$LOG_FILE"
    ip addr del "$VIP" dev "$INTERFACE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VIP-DEL] VIP $VIP_IP does not exist on $INTERFACE. Nothing to do." >> "$LOG_FILE"
fi
