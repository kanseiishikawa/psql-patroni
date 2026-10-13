FROM postgres:18

# 必要なシステムパッケージ（Python本体やコンパイル用ツール）をインストール
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    gcc \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# pipを使ってPatroniとetcd3用の依存ライブラリをまとめてインストール
RUN pip3 install --no-cache-dir --break-system-packages "patroni[etcd3,psycopg2-binary]"

USER root
RUN mkdir -p /data && chown -R postgres:postgres /data
USER postgres
