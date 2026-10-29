CREATE TABLE test_table (id int, name text);
INSERT INTO test_table VALUES (1, 'patroni-test');
INSERT INTO test_table VALUES (2, 'patroni-test');
INSERT INTO test_table VALUES (3, 'patroni-test');
CREATE PUBLICATION migration_pub FOR ALL TABLES;
