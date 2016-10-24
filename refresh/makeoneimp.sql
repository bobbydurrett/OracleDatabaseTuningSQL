-- makeoneimp takes three arguments
--
-- 1 - Oracle username
-- 2 - Oracle password
-- 3 - schema to import for
--
set echo off
set termout off
set heading off
set feedback off
set newpage none
set linesize 1000
set trimspool on
set verify off

drop table lines;
create table lines(lineno number,line varchar2(1000));
drop sequence linesseq;
create sequence linesseq;

insert into lines values (linesseq.nextval,'userid=&1/&2');
insert into lines values (linesseq.nextval,'file=exp.pipe');
insert into lines values (linesseq.nextval,'log=imp&3..log');
insert into lines values (linesseq.nextval,'buffer=1000000');
insert into lines values (linesseq.nextval,'fromuser=&3');
insert into lines values (linesseq.nextval,'touser=&3');
insert into lines values (linesseq.nextval,'ignore=Y');
insert into lines values (linesseq.nextval,'indexes=N');
insert into lines values (linesseq.nextval,'constraints=N');
insert into lines values (linesseq.nextval,'grants=N');
insert into lines values (linesseq.nextval,'skip_unusable_indexes=Y');
insert into lines values (linesseq.nextval,'commit=Y');
insert into lines values (linesseq.nextval,'analyze=N');

-- need pl/sql logic to generate tables= parameter
-- if partitions exist then use partition syntax.
-- just get tables for the particular owner

drop table oneownertablelist;

create table oneownertablelist as
select table_name,partition_name from tablelist where table_owner='&3';

declare

  current_table_number number;
  number_of_tables number;
  CURSOR TAB_CURSOR IS 
    SELECT
      TABLE_NAME,
      PARTITION_NAME
    FROM ONEOWNERTABLELIST;
  TAB_REC TAB_CURSOR%ROWTYPE;
  
  output_line varchar2(1000);
  
begin
  select count(*) into number_of_tables from oneownertablelist;

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
      output_line := output_line || tab_rec.table_name;
    else
      output_line := output_line || tab_rec.table_name||
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

spool imp&3..par

select line from lines order by lineno;

spool off
