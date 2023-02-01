set linesize 32000
set pagesize 1000
set echo on
set termout on
set trimspool on
set serveroutput on size 1000000

spool spacetest.log

select * from v$version;

show parameter block_size

select * from nls_database_parameters where parameter='NLS_CHARACTERSET';

drop table test;

-- create table with a clob chunk 1 block nocache logging in row

CREATE TABLE TEST
(
  A NUMBER,
  B CLOB
)
LOB (B) STORE AS BASICFILE (
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
  NOCACHE
  LOGGING);
  
-- insert one in row blog and one out of row
  
insert into test values (1,'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
insert into test select a+1,b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b||b from test;

commit;

-- gather stats

execute dbms_stats.gather_table_stats(NULL,'TEST');

-- show lob lengths

select
a,
dbms_lob.getlength(B)
from test;

select
sum(dbms_lob.getlength(B))
from test;

-- table segment size

select 
substr(SEGMENT_NAME,1,25) Name,
substr(SEGMENT_TYPE,1,20) Type,
bytes,
INITIAL_EXTENT,
NEXT_EXTENT,
MIN_EXTENTS,
PCT_INCREASE
from
user_segments 
where
segment_name = 'TEST';

-- lob segment size

select 
substr(SEGMENT_NAME,1,25) Name,
substr(SEGMENT_TYPE,1,20) Type,
bytes,
INITIAL_EXTENT,
NEXT_EXTENT,
MIN_EXTENTS,
PCT_INCREASE
from
user_segments 
where
segment_name in
(select 
segment_name
from user_lobs 
where table_name='TEST');

-- table size stats

select
num_rows,
BLOCKS,
AVG_ROW_LEN,
num_rows * AVG_ROW_LEN,
blocks * 8192
from 
USER_TABLES
where
table_name='TEST';

-- pl/sql calls

DECLARE 

total_blocks NUMBER;
total_bytes NUMBER;
unused_blocks NUMBER;
unused_bytes NUMBER;
lastextf NUMBER;
last_extb NUMBER;
lastusedblock NUMBER;

username varchar2(30);
lobsegname varchar2(30);

unformatted_blocks NUMBER;
unformatted_bytes  NUMBER;
fs1_blocks         NUMBER;
fs1_bytes          NUMBER;
fs2_blocks         NUMBER;
fs2_bytes          NUMBER;
fs3_blocks         NUMBER;
fs3_bytes          NUMBER;
fs4_blocks         NUMBER;
fs4_bytes          NUMBER;
full_blocks        NUMBER;
full_bytes         NUMBER;

BEGIN

-- get my user name

select user into username from dual;

dbms_output.put_line('--------------------------------------');
dbms_output.put_line('username = '||username);
dbms_output.put_line('--------------------------------------');

DBMS_SPACE.UNUSED_SPACE(username, 'TEST', 'TABLE',
total_blocks,
total_bytes,
unused_blocks, 
unused_bytes, 
lastextf,
last_extb, 
lastusedblock);

dbms_output.put_line('--------------------------------------');
dbms_output.put_line('DBMS_SPACE.UNUSED_SPACE TEST TABLE');
dbms_output.put_line('--------------------------------------');

dbms_output.put_line('total_blocks = '||total_blocks);
dbms_output.put_line('total_bytes = '||total_bytes);
dbms_output.put_line('unused_blocks = '||unused_blocks);
dbms_output.put_line('unused_bytes = '||unused_bytes);
dbms_output.put_line('lastextf = '||lastextf);
dbms_output.put_line('last_extb = '||last_extb);
dbms_output.put_line('lastusedblock = '||lastusedblock);

-- get lob segment name

select segment_name into lobsegname
from user_lobs
where table_name='TEST' and column_name='B';

dbms_output.put_line('--------------------------------------');
dbms_output.put_line('lobsegname = '||lobsegname);
dbms_output.put_line('--------------------------------------');

DBMS_SPACE.UNUSED_SPACE(username, lobsegname, 'LOB',
total_blocks,
total_bytes,
unused_blocks, 
unused_bytes, 
lastextf,
last_extb, 
lastusedblock);

dbms_output.put_line('--------------------------------------');
dbms_output.put_line('DBMS_SPACE.UNUSED_SPACE LOB');
dbms_output.put_line('--------------------------------------');

dbms_output.put_line('total_blocks = '||total_blocks);
dbms_output.put_line('total_bytes = '||total_bytes);
dbms_output.put_line('unused_blocks = '||unused_blocks);
dbms_output.put_line('unused_bytes = '||unused_bytes);
dbms_output.put_line('lastextf = '||lastextf);
dbms_output.put_line('last_extb = '||last_extb);
dbms_output.put_line('lastusedblock = '||lastusedblock);

DBMS_SPACE.SPACE_USAGE(username, 'TEST', 'TABLE',
unformatted_blocks      ,
unformatted_bytes       ,
fs1_blocks              ,
fs1_bytes               ,
fs2_blocks              ,
fs2_bytes               ,
fs3_blocks              ,
fs3_bytes               ,
fs4_blocks              ,
fs4_bytes               ,
full_blocks             ,
full_bytes        
); 

dbms_output.put_line('--------------------------------------');
dbms_output.put_line('DBMS_SPACE.SPACE_USAGE TEST TABLE');
dbms_output.put_line('--------------------------------------');

dbms_output.put_line('unformatted_blocks = '||unformatted_blocks);
dbms_output.put_line('unformatted_bytes = '||unformatted_bytes);
dbms_output.put_line('fs1_blocks = '||fs1_blocks);
dbms_output.put_line('fs1_bytes = '||fs1_bytes);
dbms_output.put_line('fs2_blocks = '||fs2_blocks);
dbms_output.put_line('fs2_bytes = '||fs2_bytes);
dbms_output.put_line('fs3_blocks = '||fs3_blocks);
dbms_output.put_line('fs3_bytes = '||fs3_bytes);
dbms_output.put_line('fs4_blocks = '||fs4_blocks);
dbms_output.put_line('fs4_bytes = '||fs4_bytes);
dbms_output.put_line('full_blocks = '||full_blocks);
dbms_output.put_line('full_bytes = '||full_bytes);

DBMS_SPACE.SPACE_USAGE(username, lobsegname, 'LOB',
unformatted_blocks      ,
unformatted_bytes       ,
fs1_blocks              ,
fs1_bytes               ,
fs2_blocks              ,
fs2_bytes               ,
fs3_blocks              ,
fs3_bytes               ,
fs4_blocks              ,
fs4_bytes               ,
full_blocks             ,
full_bytes        
); 

dbms_output.put_line('--------------------------------------');
dbms_output.put_line('DBMS_SPACE.SPACE_USAGE LOB');
dbms_output.put_line('--------------------------------------');

dbms_output.put_line('unformatted_blocks = '||unformatted_blocks);
dbms_output.put_line('unformatted_bytes = '||unformatted_bytes);
dbms_output.put_line('fs1_blocks = '||fs1_blocks);
dbms_output.put_line('fs1_bytes = '||fs1_bytes);
dbms_output.put_line('fs2_blocks = '||fs2_blocks);
dbms_output.put_line('fs2_bytes = '||fs2_bytes);
dbms_output.put_line('fs3_blocks = '||fs3_blocks);
dbms_output.put_line('fs3_bytes = '||fs3_bytes);
dbms_output.put_line('fs4_blocks = '||fs4_blocks);
dbms_output.put_line('fs4_bytes = '||fs4_bytes);
dbms_output.put_line('full_blocks = '||full_blocks);
dbms_output.put_line('full_bytes = '||full_bytes);

END;
/

spool off


