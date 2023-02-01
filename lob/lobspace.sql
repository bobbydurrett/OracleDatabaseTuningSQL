set linesize 32000
set pagesize 1000
set long 2000000000
set longchunksize 1000
set head off;
set verify off;
set termout off;
 
column u new_value us noprint;
column n new_value ns noprint;
 
select name n from v$database;
select user u from dual;
set sqlprompt &ns:&us>

set head on
set echo on
set termout on
set trimspool on

set timing on
set autotrace on
set serveroutput on size 1000000

spool &ns.lobspace.log

declare 
  -- parameters to update:
  
  tabowner varchar2(30) := 'MYOWNER';
  tabname varchar2(30) := 'MYTABLE';
  lobcolumn varchar2(30) := 'MYLOBCOLUMN';
  inlinecutoff number := 3964;
  usableperblock number := 8132;

  -- rest of variables

  query varchar2(1000);
  
  TYPE LenCurTyp  IS REF CURSOR;
  len_cursor LenCurTyp;
  lob_size number;
  lobsegment varchar2(30);
  lobsegsize number;

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
  
  row_count number := 0;
  inline_count number := 0;
  lobseg_count number := 0;
  roundedupsize number;
  totalinlobsegsize number := 0;

begin

  -- get lob segment name
  
  select segment_name into lobsegment
  from dba_lobs 
  where 
  owner = tabowner and
  table_name=tabname;
    
  -- get size of lob segment
  
  select bytes into lobsegsize 
  from dba_segments 
  where
  owner = tabowner and
  segment_name=lobsegment;
  
  -- get number of full blocks in lob segment
  
  DBMS_SPACE.SPACE_USAGE(tabowner, lobsegment, 'LOB',
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
  
  -- loop through rows getting lob sizes
  
  query := 'select dbms_lob.getlength('||lobcolumn||') len from '||tabowner||'.'||tabname;

  OPEN len_cursor FOR query;

  LOOP
    FETCH len_cursor INTO lob_size;
    EXIT WHEN len_cursor%NOTFOUND;
    
    row_count := row_count + 1;
    
    if lob_size is null then
      lob_size := 0;
    end if;
    
    if lob_size <= inlinecutoff then
      inline_count := inline_count + 1;
    else
      lobseg_count := lobseg_count + 1;
      
      roundedupsize := usableperblock * ceil(lob_size/usableperblock);
    
      totalinlobsegsize := totalinlobsegsize + roundedupsize;
    end if;
        
  END LOOP;

  CLOSE len_cursor;

  -- final output

  dbms_output.put_line('--------------------------------------');
  dbms_output.put_line('Table owner = '||tabowner);
  dbms_output.put_line('Table name = '||tabname);
  dbms_output.put_line('LOB column name = '||lobcolumn);
  dbms_output.put_line('--------------------------------------');
  dbms_output.put_line('Number of rows in table = '||to_char(row_count));
  dbms_output.put_line('Number of rows with lob in table row = '||to_char(inline_count));
  dbms_output.put_line('Number of rows with lob in lob segment = '||to_char(lobseg_count));
  dbms_output.put_line('Total lob segment size = '||to_char(lobsegsize/(1024*1024))||' megabytes');
  dbms_output.put_line('Total size of full lob segment blocks = '||to_char((full_blocks*usableperblock)/(1024*1024))||' megabytes');
  dbms_output.put_line('Total lob space used in lob segment = '||to_char(totalinlobsegsize/(1024*1024))||' megabytes');
  dbms_output.put_line('--------------------------------------');
  dbms_output.put_line('Percentage of full blocks used = '||to_char(trunc((100*totalinlobsegsize)/(full_blocks*usableperblock)))||'%');

end;
/

spool off
