CREATE DATABASE IF NOT EXISTS example ON CLUSTER replicated_cluster;

CREATE TABLE IF NOT EXISTS example.table_data ON CLUSTER replicated_cluste
(
    id UInt32,
    name String,
    cdate DateTime
)
ENGINE ReplicatedMergeTree('/clickhouse/tables/{database}/{shard}/{table}', '{replica}')
ORDER BY (id)
PARTITION BY (cdate);

CREATE TABLE IF NOT EXISTS example.table ON CLUSTER replicated_cluster
(
    id UInt32,
    name String,
    cdate DateTime
)
ENGINE = Distributed(
    'replicated_cluster',
    'example',
    'table_data',
    rand()
);


-- system.clusters_replicas - Distributed-таблица над system.replicas

SELECT database, table, engine, zookeeper_path, replica_name, replica_path, replica_is_active FROM system.clusters_replicas
WHERE database = 'example'
    AND table = 'table_data';

-- +--------+----------+-------------------+---------------------------------------+------------+--------------------------------------------------------+-------------------------+
-- |database|table     |engine             |zookeeper_path                         |replica_name|replica_path                                            |replica_is_active        |
-- +--------+----------+-------------------+---------------------------------------+------------+--------------------------------------------------------+-------------------------+
-- |example |table_data|ReplicatedMergeTree|/clickhouse/tables/example/1/table_data|node-01     |/clickhouse/tables/example/1/table_data/replicas/node-01|{'node-01':1,'node-02':1}|
-- |example |table_data|ReplicatedMergeTree|/clickhouse/tables/example/1/table_data|node-02     |/clickhouse/tables/example/1/table_data/replicas/node-02|{'node-01':1,'node-02':1}|
-- |example |table_data|ReplicatedMergeTree|/clickhouse/tables/example/2/table_data|node-03     |/clickhouse/tables/example/2/table_data/replicas/node-03|{'node-03':1,'node-04':1}|
-- |example |table_data|ReplicatedMergeTree|/clickhouse/tables/example/2/table_data|node-04     |/clickhouse/tables/example/2/table_data/replicas/node-04|{'node-03':1,'node-04':1}|
-- |example |table_data|ReplicatedMergeTree|/clickhouse/tables/example/3/table_data|node-05     |/clickhouse/tables/example/3/table_data/replicas/node-05|{'node-05':1,'node-06':1}|
-- |example |table_data|ReplicatedMergeTree|/clickhouse/tables/example/3/table_data|node-06     |/clickhouse/tables/example/3/table_data/replicas/node-06|{'node-05':1,'node-06':1}|
-- +--------+----------+-------------------+---------------------------------------+------------+--------------------------------------------------------+-------------------------+
