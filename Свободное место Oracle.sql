---------------------------------------------------------------
-- Сводка места по табличным пространствам
----------------------------------------------------------------
SELECT  free.tablespace_name TABLESPACE, 
    ROUND(files.bytes / 1073741824, 2) gb_total,
    ROUND((files.bytes - free.bytes)  / 1073741824, 2) gb_used,      
    ROUND(free.bytes  / files.bytes * 100) || '%' "%FREE" 
FROM
  (
    SELECT tablespace_name, SUM(bytes) bytes FROM dba_free_space
    GROUP BY tablespace_name
  ) free,
  (
    SELECT tablespace_name, SUM(bytes) bytes FROM dba_data_files 
    GROUP BY tablespace_name
  ) files
WHERE 
  free.tablespace_name = files.tablespace_name
  and files.tablespace_name = 'TRNDATA'
  
--------------------------------------------------------------
-- просто сегменты хранидища
--------------------------------------------------------------
select s.owner, s.segment_name, s.segment_type, round(sum(bytes)/(1024*1024*1024),4) as sz, sum(blocks) as blocks 
from dba_segments s 
where
  s.owner in ('BCKP'/*'STORAGES','STORAGE_SOURCE'*/)
  --s.tablespace_name = 'TRNDATA' --s.owner='AIS' --and s.owner in ('STORAGES','STORAGE_SOURCE','MOTOR','MEDIC','TOUR') 
group by s.owner, s.segment_name, s.segment_type
--having round(sum(bytes)/(1024*1024*1024),2) >0
order by s.owner, sz desc 


-------------------------------------------------------------
-- Какие сегменты занимают меcто (LOB)
------------------------------------------------------------
select s.*, l.TABLE_NAME, l.COLUMN_NAME from
(
select owner, segment_name, round(sum(bytes)/(1024*1024*1024),2) as sz, sum(blocks) as blocks 
from dba_segments where tablespace_name='SMLOBTBS' --and owner = 'STORAGE_HIST'
group by owner, segment_name
having round(sum(bytes)/(1024*1024*1024),2) >0
) s, dba_lobs l
where s.segment_name = l.segment_name and s.sz > 1
order by s.sz desc, s.owner
order by s.owner, s.sz desc


Select  owner, table_name, column_name, segment_name, index_name, tablespace_name
From DBA_LOBS  
Where /*Owner='SYSTEM' and*/ 
  segment_name = 'SYS_LOB0000147231C00009$$' 
  
-----------------------------------------------------------------------  
-- запрос свободного места ВРЕМЕННЫХ табличных пространств
-----------------------------------------------------------------------
SELECT a.tablespace_name, total_bytes/1024/1024 AS "Total, MB", used_mbytes AS "Used, MB",
  (total_bytes/1024/1024 - used_mbytes) AS "Free, MB" FROM
    (SELECT tablespace_name, SUM(bytes_used + bytes_free) AS total_bytes
      FROM v$temp_space_header GROUP BY tablespace_name) a,
    (SELECT tablespace_name, used_blocks*8/1024 AS used_mbytes FROM v$sort_segment) b
WHERE a.tablespace_name=b.tablespace_name
  
  
------------------------------------------------------------------------
-- очистка пустых LOB при MOVE
------------------------------------------------------------------------
ALTER TABLE DOCFLOW.MESSAGES move lob (MESSAGEBODY) STORE AS MESSAGEBODY (TABLESPACE SMLOBTBS)



with sg as (
select s.owner, s.segment_name, round(sum(bytes)/(1024*1024*1024),2) as sz, sum(blocks) as blocks 
from dba_segments s where s.owner='HIST' --and s.owner in ('STORAGES','STORAGE_SOURCE','MOTOR','MEDIC','TOUR') --and s.owner in ('STORAGE_HIST')--('STORAGES','STORAGE_SOURCE','MOTOR','MEDIC','TOUR')
and segment_name  like 'SYS_LOB%'
group by s.owner, s.segment_name
having round(sum(bytes)/(1024*1024*1024),2) >0
order by s.owner, sz desc 
)
select   sg.owner, l.table_name, l.column_name, sg.sz, sg.segment_name, l.index_name, l.tablespace_name
From DBA_LOBS l, sg
 Where l.Owner=sg.owner and l.SEGMENT_NAME = sg.segment_name












