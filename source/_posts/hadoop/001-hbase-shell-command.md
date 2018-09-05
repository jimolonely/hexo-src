---
title: hbase shell命令
tags:
  - hbase
p: hadoop/001-hbase-shell-command
date: 2018-09-05 08:01:35
---

本篇关于hbase常用命令。

{% asset_img 000.png %}

# 进入shell
```
# hbase shell
Java HotSpot(TM) 64-Bit Server VM warning: Using incremental CMS is deprecated and will likely be removed in a future release
18/09/05 08:05:08 INFO Configuration.deprecation: hadoop.native.lib is deprecated. Instead, use io.native.lib.available
HBase Shell; enter 'help<RETURN>' for list of supported commands.
Type "exit<RETURN>" to leave the HBase Shell
Version 1.2.0-cdh5.11.1, rUnknown, Thu Jun  1 10:19:43 PDT 2017

hbase(main):001:0>
```
## 查看有哪些命令
```
hbase(main):006:0> table help
HBase Shell, version 1.2.0-cdh5.11.1, rUnknown, Thu Jun  1 10:19:43 PDT 2017
Type 'help "COMMAND"', (e.g. 'help "get"' -- the quotes are necessary) for help on a specific command.
Commands are grouped. Type 'help "COMMAND_GROUP"', (e.g. 'help "general"') for help on a command group.

COMMAND GROUPS:
  Group name: general
  Commands: status, table_help, version, whoami

  Group name: ddl
  Commands: alter, alter_async, alter_status, create, describe, disable, disable_all, drop, drop_all, enable, enable_all, exists, get_table, is_disabled, is_enabled, list, locate_region, show_filters

  Group name: namespace
  Commands: alter_namespace, create_namespace, describe_namespace, drop_namespace, list_namespace, list_namespace_tables

  Group name: dml
  Commands: append, count, delete, deleteall, get, get_counter, get_splits, incr, put, scan, truncate, truncate_preserve

  Group name: tools
  Commands: assign, balance_switch, balancer, balancer_enabled, catalogjanitor_enabled, catalogjanitor_run, catalogjanitor_switch, close_region, compact, compact_mob, compact_rs, flush, major_compact, major_compact_mob, merge_region, move, normalize, normalizer_enabled, normalizer_switch, split, trace, unassign, wal_roll, zk_dump

  Group name: replication
  Commands: add_peer, append_peer_tableCFs, disable_peer, disable_table_replication, enable_peer, enable_table_replication, get_peer_config, list_peer_configs, list_peers, list_replicated_tables, remove_peer, remove_peer_tableCFs, set_peer_tableCFs, show_peer_tableCFs, update_peer_config

  Group name: snapshots
  Commands: clone_snapshot, delete_all_snapshot, delete_snapshot, list_snapshots, restore_snapshot, snapshot

  Group name: configuration
  Commands: update_all_config, update_config

  Group name: quotas
  Commands: list_quotas, set_quota

  Group name: security
  Commands: grant, list_security_capabilities, revoke, user_permission

  Group name: procedures
  Commands: abort_procedure, list_procedures

  Group name: visibility labels
  Commands: add_labels, clear_auths, get_auths, list_labels, set_auths, set_visibility

  Group name: rsgroup
  Commands: add_rsgroup, balance_rsgroup, get_rsgroup, get_server_rsgroup, get_table_rsgroup, list_rsgroups, move_servers_rsgroup, move_tables_rsgroup, remove_rsgroup
```

可以看到，hbase已经给我们分好类了。

# 通用命令
## status
```
hbase(main):001:0> status
1 active master, 1 backup masters, 6 servers, 0 dead, 11.0000 average load

hbase(main):003:0> status 'summary'
1 active master, 1 backup masters, 6 servers, 0 dead, 11.0000 average load

hbase(main):002:0> status 'simple'
active master:  hadoop5:60000 1534920686752
1 backup masters
    hadoop4:60000 1535506688049
6 live servers
    hadoop5:60020 1534920686459
        requestsPerSecond=0.0, numberOfOnlineRegions=12, usedHeapMB=4468, maxHeapMB=16275, numberOfStores=12, numberOfStorefiles=29, storefileUncompressedSizeMB=10506, storefileSizeMB=10509, compressionRatio=1.0003, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=2572948, writeRequestsCount=11596818, rootIndexSizeKB=586, totalStaticIndexSizeKB=24278, totalStaticBloomSizeKB=16265, totalCompactingKVs=23177559, currentCompactedKVs=23177559, compactionProgressPct=1.0, coprocessors=[SecureBulkLoadEndpoint]
    hadoop4:60020 1535506702569
        requestsPerSecond=43.0, numberOfOnlineRegions=13, usedHeapMB=3410, maxHeapMB=16275, numberOfStores=14, numberOfStorefiles=30, storefileUncompressedSizeMB=5037, storefileSizeMB=5039, compressionRatio=1.0004, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=27841408, writeRequestsCount=6925128, rootIndexSizeKB=513, totalStaticIndexSizeKB=10852, totalStaticBloomSizeKB=15973, totalCompactingKVs=12727622, currentCompactedKVs=12727622, compactionProgressPct=1.0, coprocessors=[MultiRowMutationEndpoint, SecureBulkLoadEndpoint]
    hadoop7:60020 1534920685705
        requestsPerSecond=0.0, numberOfOnlineRegions=10, usedHeapMB=6894, maxHeapMB=16275, numberOfStores=10, numberOfStorefiles=28, storefileUncompressedSizeMB=6536, storefileSizeMB=6538, compressionRatio=1.0003, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=5364554, writeRequestsCount=9582529, rootIndexSizeKB=582, totalStaticIndexSizeKB=14239, totalStaticBloomSizeKB=17340, totalCompactingKVs=9000095, currentCompactedKVs=9000095, compactionProgressPct=1.0, coprocessors=[SecureBulkLoadEndpoint]
    hadoop6:60020 1534920685863
        requestsPerSecond=0.0, numberOfOnlineRegions=9, usedHeapMB=8409, maxHeapMB=16275, numberOfStores=9, numberOfStorefiles=17, storefileUncompressedSizeMB=7896, storefileSizeMB=7899, compressionRatio=1.0004, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=11236762, writeRequestsCount=4793387, rootIndexSizeKB=277, totalStaticIndexSizeKB=18459, totalStaticBloomSizeKB=13756, totalCompactingKVs=35614802, currentCompactedKVs=35614802, compactionProgressPct=1.0, coprocessors=[SecureBulkLoadEndpoint]
    hadoop8:60020 1534920687951
        requestsPerSecond=0.0, numberOfOnlineRegions=10, usedHeapMB=3580, maxHeapMB=16275, numberOfStores=10, numberOfStorefiles=19, storefileUncompressedSizeMB=3529, storefileSizeMB=3532, compressionRatio=1.0009, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=3473967, writeRequestsCount=4396196, rootIndexSizeKB=150, totalStaticIndexSizeKB=7659, totalStaticBloomSizeKB=9324, totalCompactingKVs=9331946, currentCompactedKVs=9331946, compactionProgressPct=1.0, coprocessors=[SecureBulkLoadEndpoint]
    hadoop9:60020 1534920685661
        requestsPerSecond=0.0, numberOfOnlineRegions=12, usedHeapMB=4199, maxHeapMB=16275, numberOfStores=14, numberOfStorefiles=22, storefileUncompressedSizeMB=5489, storefileSizeMB=5491, compressionRatio=1.0004, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=4352374, writeRequestsCount=5654792, rootIndexSizeKB=193, totalStaticIndexSizeKB=11357, totalStaticBloomSizeKB=14968, totalCompactingKVs=16062162, currentCompactedKVs=16062162, compactionProgressPct=1.0, coprocessors=[SecureBulkLoadEndpoint]
0 dead servers
Aggregate load: 43, regions: 66

hbase(main):004:0> status 'detailed'
version 1.2.0-cdh5.11.1
0 regionsInTransition
active master:  hadoop5:60000 1534920686752
1 backup masters
    hadoop4:60000 1535506688049
master coprocessors: []
6 live servers
    hadoop5:60020 1534920686459
        requestsPerSecond=0.0, numberOfOnlineRegions=12, usedHeapMB=4472, maxHeapMB=16275, numberOfStores=12, numberOfStorefiles=29, storefileUncompressedSizeMB=10506, storefileSizeMB=10509, compressionRatio=1.0003, memstoreSizeMB=0, storefileIndexSizeMB=0, readRequestsCount=2572948, writeRequestsCount=11596818, rootIndexSizeKB=586, totalStaticIndexSizeKB=24278, totalStaticBloomSizeKB=16265, totalCompactingKVs=23177559, currentCompactedKVs=23177559, compactionProgressPct=1.0, coprocessors=[SecureBulkLoadEndpoint]
        "monitor120History,,1535746236467.697bd51213784f28ebbfc59d3a5a713c."
....
....
```
## version
```
hbase(main):005:0> version
1.2.0-cdh5.11.1, rUnknown, Thu Jun  1 10:19:43 PDT 2017
```
## table help
见上面
## whoami
```
hbase(main):008:0> whoami
root (auth:SIMPLE)
    groups: root
```
# DDL(数据描述语言)
也就是一些宏观的结构操作，一般针对表。
## create
```
hbase(main):010:0> create 't_jimo','cf1'
0 row(s) in 1.3430 seconds

=> Hbase::Table - t_jimo
```
## list
```
hbase(main):011:0> list
TABLE
homedata
t_blog
t_jimo
testKfkBulkload
```
## describe
```
hbase(main):012:0> describe 't_jimo'
Table t_jimo is ENABLED
t_jimo
COLUMN FAMILIES DESCRIPTION
{NAME => 'cf1', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSIONS => '0', BLOCKCACHE
 => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
1 row(s) in 0.1270 seconds
```
## disable & disable_all
```
hbase(main):013:0> disable 't_jimo'
0 row(s) in 2.2540 seconds
```
## enable
```
hbase(main):014:0> enable 't_jimo'
0 row(s) in 1.2740 seconds
```
## exists
```
hbase(main):015:0> exists 't_jimo'
Table t_jimo does exist
0 row(s) in 0.0150 seconds

hbase(main):016:0> exists 'hehe'
Table hehe does not exist
0 row(s) in 0.0120 seconds
```
## show_filters
```
hbase(main):017:0> show_filters
DependentColumnFilter
KeyOnlyFilter
ColumnCountGetFilter
SingleColumnValueFilter
PrefixFilter
SingleColumnValueExcludeFilter
FirstKeyOnlyFilter
ColumnRangeFilter
TimestampsFilter
FamilyFilter
QualifierFilter
ColumnPrefixFilter
RowFilter
MultipleColumnPrefixFilter
InclusiveStopFilter
PageFilter
ValueFilter
ColumnPaginationFilter
```
## alter
```
hbase(main):020:0> alter 't_jimo',{ NAME=>'f1',VERSIONS=>2 }
Unknown argument ignored: f1
Unknown argument ignored: VERSIONS
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 1.9340 seconds

  hbase> alter 't1', { NAME => 'f1', VERSIONS => 3 },
   { MAX_FILESIZE => '134217728' }, { METHOD => 'delete', NAME => 'f2' },
   OWNER => 'johndoe', METADATA => { 'mykey' => 'myvalue' }
```
## drop & drop_all
drop前先要disable
```
hbase(main):040:0> disable 't_jimo'
0 row(s) in 2.4140 seconds

hbase(main):041:0> drop 't_jimo'
0 row(s) in 1.2380 seconds
```
# DML(数据操作语言)
## count
```
hbase(main):022:0> count 't_jimo'
0 row(s) in 0.0850 seconds

=> 0
hbase(main):023:0> count 't_jimo',CACHE=>1000
0 row(s) in 0.0110 seconds

=> 0
```
## put
```
hbase(main):024:0> put 't_jimo','r1','cf1:c1','hehe',10
0 row(s) in 0.1450 seconds

hbase(main):025:0> put 't_jimo','r1','cf1:c1','jimo',20
0 row(s) in 0.0060 seconds

hbase(main):026:0> put 't_jimo','r2','cf1:c1','kaka',30
0 row(s) in 0.0080 seconds
```
看下示例：
```
  hbase> put 'ns1:t1', 'r1', 'c1', 'value'
  hbase> put 't1', 'r1', 'c1', 'value'
  hbase> put 't1', 'r1', 'c1', 'value', ts1
  hbase> put 't1', 'r1', 'c1', 'value', {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> put 't1', 'r1', 'c1', 'value', ts1, {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> put 't1', 'r1', 'c1', 'value', ts1, {VISIBILITY=>'PRIVATE|SECRET'}
```
## get
默认只返回最新那条
```
hbase(main):029:0> get 't_jimo','r1'
COLUMN                                                CELL
 cf1:c1                                               timestamp=20, value=jimo
1 row(s) in 0.0210 seconds
```
下面是常用语法：
```
  hbase> get 'ns1:t1', 'r1'
  hbase> get 't1', 'r1'
  hbase> get 't1', 'r1', {TIMERANGE => [ts1, ts2]}
  hbase> get 't1', 'r1', {COLUMN => 'c1'}
  hbase> get 't1', 'r1', {COLUMN => ['c1', 'c2', 'c3']}
  hbase> get 't1', 'r1', {COLUMN => 'c1', TIMESTAMP => ts1}
  hbase> get 't1', 'r1', {COLUMN => 'c1', TIMERANGE => [ts1, ts2], VERSIONS => 4}
  hbase> get 't1', 'r1', {COLUMN => 'c1', TIMESTAMP => ts1, VERSIONS => 4}
  hbase> get 't1', 'r1', {FILTER => "ValueFilter(=, 'binary:abc')"}
  hbase> get 't1', 'r1', 'c1'
  hbase> get 't1', 'r1', 'c1', 'c2'
  hbase> get 't1', 'r1', ['c1', 'c2']
  hbase> get 't1', 'r1', {COLUMN => 'c1', ATTRIBUTES => {'mykey'=>'myvalue'}}
  hbase> get 't1', 'r1', {COLUMN => 'c1', AUTHORIZATIONS => ['PRIVATE','SECRET']}
  hbase> get 't1', 'r1', {CONSISTENCY => 'TIMELINE'}
  hbase> get 't1', 'r1', {CONSISTENCY => 'TIMELINE', REGION_REPLICA_ID => 1}
```
## scan
```
hbase(main):030:0> scan 't_jimo'
ROW                                                   COLUMN+CELL
 r1                                                   column=cf1:c1, timestamp=20, value=jimo
 r2                                                   column=cf1:c1, timestamp=30, value=kaka
2 row(s) in 0.0110 seconds

hbase(main):031:0> scan 't_jimo',{LIMIT=>1}
ROW                                                   COLUMN+CELL
 r1                                                   column=cf1:c1, timestamp=20, value=jimo
1 row(s) in 0.0060 seconds
```
## incr
```
  hbase> incr 'ns1:t1', 'r1', 'c1'
  hbase> incr 't1', 'r1', 'c1'
  hbase> incr 't1', 'r1', 'c1', 1
  hbase> incr 't1', 'r1', 'c1', 10
  hbase> incr 't1', 'r1', 'c1', 10, {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> incr 't1', 'r1', 'c1', {ATTRIBUTES=>{'mykey'=>'myvalue'}}
  hbase> incr 't1', 'r1', 'c1', 10, {VISIBILITY=>'PRIVATE|SECRET'}
```
## delete & deleteall
```
hbase(main):033:0> delete 't_jimo','r1','cf1:c1'
0 row(s) in 0.0460 seconds

hbase(main):034:0> scan 't_jimo'
ROW                                                   COLUMN+CELL
 r2                                                   column=cf1:c1, timestamp=30, value=kaka
1 row(s) in 0.0060 seconds
```
示例：
```
  hbase> delete 'ns1:t1', 'r1', 'c1', ts1
  hbase> delete 't1', 'r1', 'c1', ts1
  hbase> delete 't1', 'r1', 'c1', ts1, {VISIBILITY=>'PRIVATE|SECRET'}
```
## truncate
```
hbase(main):037:0> truncate 't_jimo'
Truncating 't_jimo' table (it may take a while):
 - Disabling table...
 - Truncating table...
0 row(s) in 3.4020 seconds

hbase(main):038:0> scan 't_jimo'
ROW                                                   COLUMN+CELL
0 row(s) in 0.3210 seconds
```




