set lines 200 pages 0
col NAME for a40

  select (select INSTANCE_NAME from V$INSTANCE) as "INSTANCE_NAME"
       , NAME
       , VALUE/1024/1024 as "VALUE_MB"
    from v$parameter
   where NAME in ('sga_max_size'
                , 'sga_target'
                , 'pga_aggregate_limit'
                , 'pga_aggregate_target'
                , 'memory_max_target'
                , 'memory_target')
order by 2;
