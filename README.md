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
