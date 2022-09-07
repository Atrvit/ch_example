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
