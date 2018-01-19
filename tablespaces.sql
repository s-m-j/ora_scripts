-- Сводка места по табличным пространствам
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
  
-- Просто сегменты хранилища
select s.owner, s.segment_name, round(sum(bytes)/(1024*1024*1024),2) as sz, sum(blocks) as blocks 
from dba_segments s where s.tablespace_name = ['TABLESPACE_NAME'] 
group by s.owner, s.segment_name
having round(sum(bytes)/(1024*1024*1024),2) >0
order by s.owner, sz desc 

  
-- Какие сегменты занимают меcто (LOB)
select s.*, l.TABLE_NAME, l.COLUMN_NAME from
(
select owner, segment_name, round(sum(bytes)/(1024*1024*1024),2) as sz, sum(blocks) as blocks 
from dba_segments where /*tablespace_name=['TABLESPACE_NAME'] and*/ owner = ['OWNER']
group by owner, segment_name
having round(sum(bytes)/(1024*1024*1024),2) >0
) s, dba_lobs l
where s.segment_name = l.segment_name and s.sz > 1
order by s.sz desc, s.owner
order by s.owner, s.sz desc
