CREATE TABLE test_table (id int, name text);
INSERT INTO test_table VALUES (1, 'patroni-test');
INSERT INTO test_table VALUES (2, 'patroni-test');
INSERT INTO test_table VALUES (3, 'patroni-test');
SELECT pg_drop_replication_slot('migration_slot');
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator_password'
