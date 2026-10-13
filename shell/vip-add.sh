#!/bin/bash
VIP="172.20.0.100/24"
INTERFACE="eth0"

VIP_IP="${VIP%/*}"
LOG_FILE="/var/log/patroni_vip.log"

# すでにVIPが存在するか確認
if ! ip addr show dev "$INTERFACE" | grep -q "${VIP_IP}/"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VIP-ADD] Adding VIP $VIP to $INTERFACE" >> "$LOG_FILE"
    
    # 1. VIPの付与
    ip addr add "$VIP" dev "$INTERFACE"
    
    # 2. ネットワークへの通知 (Gratuitous ARP)
    # コンテナOSがDebian/Ubuntu系 (iputils-arping) の場合は -U、Alpineなどの場合は -A を使用します
    if command -v arping > /dev/null 2>&1; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VIP-ADD] Sending Gratuitous ARP..." >> "$LOG_FILE"
        arping -U -c 3 -I "$INTERFACE" "$VIP_IP" >> "$LOG_FILE" 2>&1
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] arping command not found. Skip GARP." >> "$LOG_FILE"
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [VIP-ADD] VIP $VIP_IP already exists on $INTERFACE" >> "$LOG_FILE"
fi
