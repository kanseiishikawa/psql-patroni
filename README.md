# Docker Patroni 

## 環境
`docker`と`docker-cmopose`のコマンドが必要になります  
`docker`コマンドは`sudo`無しで実行できるように設定してください

## 起動方法
以下のshellを実行でコンテナが立ち上がります
```
$ ./start.sh
```

## コンテナ

### etcd
3台存在する  
psqlが生きているかどうかなどの情報を共有したりどれがプライマリかの情報を持っている

### psql
3台存在する  
これらのどれかがetcdの情報を元にプライマリに決定される

### haproxy
proxyサーバー  
このサーバーを経由してアクセスすることで確実にプライマリのpsqlにアクセスできる

### app-client
接続確認を行うためのコンテナ。基本的にこちらからpsqlにアクセスしてテストする

## 構成
![構成図](data/png/composition.png)


## コマンド
- どれがプライマリかの確認を行う
```
docker exec -it pg-node-1 patronictl -c /etc/patroni/patroni.yml list
```

データを挿入して確認
```
docker exec -it app-client psql -h 172.20.0.10 -p 5432 -U postgres
CREATE TABLE test_table (id int, name text);
INSERT INTO test_table VALUES (1, 'patroni-test');
SELECT * FROM test_table;
```

### 実験用 論理レプリケーション
```
$ docker compose down --remove-orphans -v; docker-compose up -d old-pg-node-1 app-client

$ docker-compose up -d etcd1 etcd2 etcd3

$ docker-compose up -d pg-node-1

$ docker exec -it app-client psql "postgresql://postgres:mypassword@172.20.0.11:5432"
CREATE DATABASE mydb;

$ docker exec -it app-client psql "postgresql://postgres:mypassword@172.20.0.14:5432/mydb"
SELECT pg_create_physical_replication_slot('migration_slot');
SELECT pg_create_logical_replication_slot('migration_sub', 'pgoutput');

app-clientで実行
$ docker exec -it app-client bash
$ pg_dump "postgresql://postgres:mypassword@172.20.0.14:5432/mydb" -F c -f prod_data.dump
$ pg_restore -h 172.20.0.11 -U postgres -d mydb prod_data.dump

$ docker exec -it app-client psql "postgresql://postgres:mypassword@172.20.0.11:5432/mydb"
CREATE SUBSCRIPTION migration_sub
CONNECTION 'host=172.20.0.14 port=5432 user=postgres password=mypassword dbname=mydb'
PUBLICATION migration_pub
WITH (
  copy_data = false,          -- 👈 データを全削除（TRUNCATE）させない
  create_slot = false,        -- 👈 スロットはステップ1で手動作成済みのを使う
  slot_name = 'migration_sub' -- 👈 ステップ1で作ったスロット名を指定
);
```
