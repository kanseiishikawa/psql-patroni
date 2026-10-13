#!/bin/bash

# 実体スクリプトのパス
ADD_SCRIPT="/opt/patroni/vip-add.sh"
DEL_SCRIPT="/opt/patroni/vip-del.sh"

ACTION=$1
ROLE=$2
CLUSTER_NAME=$3

LOG_FILE="/var/log/patroni_vip.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ROUTER] Action: $ACTION, Role: $ROLE, Cluster: $CLUSTER_NAME" >> "$LOG_FILE"

case "$ACTION" in
    on_reload|on_restart|on_role_change)
        if [ "$ROLE" = "master" ] || [ "$ROLE" = "primary" ] || [ "$ROLE" = "leader" ]; then
            if [ -x "$ADD_SCRIPT" ]; then
                exec "$ADD_SCRIPT"
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $ADD_SCRIPT is not executable" >> "$LOG_FILE"
            fi
        else
            if [ -x "$DEL_SCRIPT" ]; then
                exec "$DEL_SCRIPT"
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $DEL_SCRIPT is not executable" >> "$LOG_FILE"
            fi
        fi
        ;;
    on_stop)
        # Patroni停止時は確実にVIPを削除
        if [ -x "$DEL_SCRIPT" ]; then
            exec "$DEL_SCRIPT"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $DEL_SCRIPT is not executable" >> "$LOG_FILE"
        fi
        ;;
esac
