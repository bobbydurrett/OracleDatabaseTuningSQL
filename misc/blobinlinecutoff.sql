set linesize 32000
set pagesize 1000
set termout on
set trimspool on
set echo off
set serveroutput on size 1000000

spool blobinlinecutoff.log

-- find inline blob cutoff point in bytes
-- for basicfile blob
-- only works if cutoff is 8192 bytes or less

-- create table with a blob

drop table test;

CREATE TABLE TEST
(
  A NUMBER,
  B BLOB
)
LOB (B) STORE AS BASICFILE (
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
  NOCACHE
  LOGGING);
  
-- insert one row with a passed number of bytes blob
 
declare
  c clob;
  b blob;
  o1 integer;
  o2 integer;
  c2 integer;
  w integer;
begin
  c := 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  c := c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c||c;
  c := substr(c,1,&&1);
  
  DBMS_LOB.CreateTemporary(b, true);
  o1 := 1;
  o2 := 1;
  c2 := 0;
  w := 0;
  DBMS_LOB.ConvertToBlob(b, c, length(c), o1, o2, 0, c2, w);
  
  insert into test values (1,b);
  commit;
  
end;
/

-- show lob length

select
dbms_lob.getlength(B) lob_length_bytes
from test;

-- show full blocks

DECLARE 

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

-- get lob segment name

select segment_name into lobsegname
from user_lobs
where table_name='TEST' and column_name='B';


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

-- if is inline blob there will be no full blocks in LOB segment

if full_blocks = 0 then
    dbms_output.put_line('inline blob');
else
    dbms_output.put_line('not inline blob');
end if;

END;
/

spool off


