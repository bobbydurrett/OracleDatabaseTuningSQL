set echo off
set termout off
set heading off
set feedback off
set newpage none
set linesize 1000
set trimspool on

drop table lines;
create table lines(lineno number,line varchar2(1000));
drop sequence linesseq;
create sequence linesseq;

insert into lines values (linesseq.nextval,'userid=&1/&2');
insert into lines values (linesseq.nextval,'file=exp.pipe');
insert into lines values (linesseq.nextval,'direct=Y');
insert into lines values (linesseq.nextval,'compress=N');
insert into lines values (linesseq.nextval,'log=exp.log');
insert into lines values (linesseq.nextval,'buffer=1000000');
insert into lines values (linesseq.nextval,'indexes=N');
insert into lines values (linesseq.nextval,'constraints=N');
insert into lines values (linesseq.nextval,'grants=N');

commit;

-- need pl/sql logic to generate tables= parameter
-- if partitions exist then use partition syntax.

declare

  current_table_number number;
  number_of_tables number;
  CURSOR TAB_CURSOR IS 
    SELECT
      TABLE_OWNER,
      TABLE_NAME,
      PARTITION_NAME
    FROM TABLELIST; 
  TAB_REC TAB_CURSOR%ROWTYPE;
  
  output_line varchar2(1000);
  
begin
  select count(*) into number_of_tables from tablelist;

  current_table_number := 0;
  
  OPEN TAB_CURSOR;
  LOOP
    output_line := '';
    
    FETCH TAB_CURSOR INTO TAB_REC;
    EXIT WHEN TAB_CURSOR%NOTFOUND;
    
    current_table_number := current_table_number + 1;
    
    if (current_table_number = 1) then
      output_line := 'TABLES=(';
    end if;
    
    if (tab_rec.partition_name is null) then
      output_line := output_line || tab_rec.table_owner ||'.'||tab_rec.table_name;
    else
      output_line := output_line || tab_rec.table_owner ||'.'||tab_rec.table_name||
        ':'||tab_rec.partition_name;
    end if;
    
    if (current_table_number = number_of_tables) then
      output_line := output_line || ')';
    else
      output_line := output_line || ',';
    end if;
    
    insert into lines values (linesseq.nextval,output_line);
    
  END LOOP;
  COMMIT;
  CLOSE TAB_CURSOR;

end;
/

commit;

spool exp.par

select line from lines order by lineno;

spool off

exit
