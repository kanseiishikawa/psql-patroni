#!/bin/bash
set -e

# 1. pg_hba.conf に Patroniからのレプリケーション接続許可を自動追記
echo "host replication replicator 172.20.0.0/16 md5" >> "$PGDATA/pg_hba.conf"
# 設定を即座にリロード
pg_ctl reload
