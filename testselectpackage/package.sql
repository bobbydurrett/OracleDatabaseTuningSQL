CREATE OR REPLACE PACKAGE TEST_SELECT AS

/*

collect_select_statements(max_number_selects,
include_pattern1,...,include_pattern10,
exclude_pattern1,...,exclude_pattern10) - This proc is run on the
the source database to collect select statements including statements that have
the include patterns and excluding those whohave the exclude patterns.  
Patterns use LIKE conditions %x%.

*/

procedure collect_select_statements(
   max_number_selects in number,
   include_pattern1 in varchar2 := '%%',
   include_pattern2 in varchar2 := '%%',
   include_pattern3 in varchar2 := '%%',
   include_pattern4 in varchar2 := '%%',
   include_pattern5 in varchar2 := '%%',
   include_pattern6 in varchar2 := '%%',
   include_pattern7 in varchar2 := '%%',
   include_pattern8 in varchar2 := '%%',
   include_pattern9 in varchar2 := '%%',
   include_pattern10 in varchar2 := '%%',
   exclude_pattern1 in varchar2 := ' ',
   exclude_pattern2 in varchar2 := ' ',
   exclude_pattern3 in varchar2 := ' ',
   exclude_pattern4 in varchar2 := ' ',
   exclude_pattern5 in varchar2 := ' ',
   exclude_pattern6 in varchar2 := ' ',
   exclude_pattern7 in varchar2 := ' ',
   exclude_pattern8 in varchar2 := ' ',
   exclude_pattern9 in varchar2 := ' ',
   exclude_pattern10 in varchar2 := ' ');
   
/*

copy_select_statements(link_name)
copies select statements from remote source database
pointed to by link_name's db link.

*/

procedure copy_select_statements(
   link_name in varchar2);

/*

update_select_statements(from_text,to_text) - updates select statement text.  
Used to change table names and schema names.  I.e. from prodschema.prodtablename 
to testschema.testtablename.

*/

procedure update_select_statements(
   from_text in varchar2,
   to_text in varchar2);
   
/*

get_explain_plans(test_name) - runs explain plan against every select recording the 
current test name.  I.e. get_explain_plans('production stats').  Plans are stored in
plan_table by sqlnumber.

*/

procedure get_explain_plans(
   test_name in varchar2);
   
/*

execute_all(test_name) - execute every query for the current test scenario.

*/

procedure execute_all(
   test_name in varchar2);

/*

execute_diff_plans(test_name,compared_to_test_name) - execute only the queries
whose plan under the current test_name differ from previous test name
compared_to_test_name.  So, if test_name is "Production stats" and
compared_to_test_name is "Empty stats" then we assume you have run get_explain_plans
for both "Production stats" and "Empty stats" and only run the sqls whose plans
are different in the two scenarios.

*/

procedure execute_diff_plans(
   v_test_name in varchar2,
   compared_to_test_name in varchar2);
   
/*

display_results(test_name,compared_to_test_name) - output results of testings in the
two scenarios.  List results from all queries that ran more than 3 times as long
with one test or the other.  Also summarize results with total elapsed time,
number of queries executed, average elapsed time, and percent improvement.

*/

procedure display_results(
   v_test_name in varchar2,
   compared_to_test_name in varchar2);
   
/*

show_explained_plan(test_name,sqlnumber) - extract plan from plan_table for given test name
and sql statement.

*/

function show_explained_plan(
   v_test_name in varchar2,
   sqlnumber in number) return CLOB;
   
/*

reexecute_errored(v_test_name) - re-execute every query for the current test scenario
that had an error.

*/

procedure reexecute_errored(
   v_test_name in varchar2);
   
/*

show_executed_plan(test_name,sqlnumber) - extract plan from plan_table for given test name
and sql statement.

*/

procedure show_executed_plan(
   v_test_name in varchar2,
   v_sqlnumber in number);
   
/*

execute_one(test_name,sqlnumber) - rerun one sql statement

*/
   
procedure execute_one(
   v_test_name in varchar2,
   v_sqlnumber in number);

END;
/
show errors

CREATE OR REPLACE PACKAGE BODY TEST_SELECT
AS

procedure collect_select_statements(
   max_number_selects in number,
   include_pattern1 in varchar2 := '%%',
   include_pattern2 in varchar2 := '%%',
   include_pattern3 in varchar2 := '%%',
   include_pattern4 in varchar2 := '%%',
   include_pattern5 in varchar2 := '%%',
   include_pattern6 in varchar2 := '%%',
   include_pattern7 in varchar2 := '%%',
   include_pattern8 in varchar2 := '%%',
   include_pattern9 in varchar2 := '%%',
   include_pattern10 in varchar2 := '%%',
   exclude_pattern1 in varchar2 := ' ',
   exclude_pattern2 in varchar2 := ' ',
   exclude_pattern3 in varchar2 := ' ',
   exclude_pattern4 in varchar2 := ' ',
   exclude_pattern5 in varchar2 := ' ',
   exclude_pattern6 in varchar2 := ' ',
   exclude_pattern7 in varchar2 := ' ',
   exclude_pattern8 in varchar2 := ' ',
   exclude_pattern9 in varchar2 := ' ',
   exclude_pattern10 in varchar2 := ' ') 
 is
    CURSOR SQL_CURSOR IS 
        SELECT DISTINCT 
            SQL_ID,
            DBID
        FROM DBA_HIST_SQLSTAT; 
    SQL_REC SQL_CURSOR%ROWTYPE;
    CURSOR TEXT_CURSOR(SQL_ID_ARGUMENT VARCHAR2,DBID_ARGUMENT NUMBER) IS 
        SELECT  
            SQL_TEXT
        FROM DBA_HIST_SQLTEXT
        WHERE 
            SQL_TEXT like include_pattern1 and
            SQL_TEXT like include_pattern2 and
            SQL_TEXT like include_pattern3 and
            SQL_TEXT like include_pattern4 and
            SQL_TEXT like include_pattern5 and
            SQL_TEXT like include_pattern6 and
            SQL_TEXT like include_pattern7 and
            SQL_TEXT like include_pattern8 and
            SQL_TEXT like include_pattern9 and
            SQL_TEXT like include_pattern10 and
            SQL_TEXT not like exclude_pattern1 and
            SQL_TEXT not like exclude_pattern2 and
            SQL_TEXT not like exclude_pattern3 and
            SQL_TEXT not like exclude_pattern4 and
            SQL_TEXT not like exclude_pattern5 and
            SQL_TEXT not like exclude_pattern6 and
            SQL_TEXT not like exclude_pattern7 and
            SQL_TEXT not like exclude_pattern8 and
            SQL_TEXT not like exclude_pattern9 and
            SQL_TEXT not like exclude_pattern10 and
            (upper(SQL_TEXT) like 'SELECT%' or
             upper(SQL_TEXT) like 'WITH%') and
            SQL_ID = SQL_ID_ARGUMENT and
            DBID = DBID_ARGUMENT;
    TEXT_REC TEXT_CURSOR%ROWTYPE;
    sqlnumber number;
    tempclob clob;
    next_sqlnumber number;
begin
-- get next sql number based on number of queries already collected
    select count(*)+1 into next_sqlnumber from select_statements;
    sqlnumber := next_sqlnumber ;
    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;

        OPEN TEXT_CURSOR(SQL_REC.SQL_ID,SQL_REC.DBID);
        LOOP
            FETCH TEXT_CURSOR INTO TEXT_REC;
            EXIT WHEN TEXT_CURSOR%NOTFOUND;
            insert into select_statements values (sqlnumber,TEXT_REC.SQL_TEXT);
            commit;
            sqlnumber := sqlnumber + 1;
         END LOOP;
        CLOSE TEXT_CURSOR;
        EXIT WHEN sqlnumber >= (max_number_selects+next_sqlnumber);
     END LOOP;
    CLOSE SQL_CURSOR;
end collect_select_statements;

procedure copy_select_statements(
   link_name in varchar2)
is
begin
  execute immediate 'truncate table select_statements';
  execute immediate 'insert into select_statements select * from '||
    'select_statements@'||link_name;
  commit;
end copy_select_statements;
 
procedure update_error(
v_test_name in varchar2,
v_sqlnumber in number,
v_sqlerrm in varchar2) 
is
row_cnt number;
trimmed_errm varchar2(64);
begin

  trimmed_errm := substr(v_sqlerrm,1,64);

  select count(*) into row_cnt
  from test_results t
  where 
  t.test_name=v_test_name and
  t.sqlnumber=v_sqlnumber;
  
  if row_cnt > 0 then
    update test_results t
    set 
    error_message=trimmed_errm
    where 
      t.test_name=v_test_name and
      t.sqlnumber=v_sqlnumber;
  else
    insert into test_results 
    (test_name,sqlnumber,error_message)
    values (
      v_test_name,
      v_sqlnumber,
      trimmed_errm);
  end if;
  commit;

end update_error;
 
procedure update_select_statements(
   from_text in varchar2,
   to_text in varchar2) 
 is
begin

update select_statements
set SQL_TEXT = replace(SQL_TEXT,from_text,to_text);

commit;

end update_select_statements;

procedure update_explain_plan_hash(
v_test_name in varchar2,
v_sqlnumber in number) 
 is
    planoutput clob;
    plan_hash_value number;
    row_cnt number;
    
begin

-- check for failed explain plan - 0 plan_hash_value

  begin
    select t.PLAN_TABLE_OUTPUT 
    into planoutput 
    from table(dbms_xplan.display('PLAN_TABLE',v_test_name||to_char(v_sqlnumber),'BASIC')) t
    where t.plan_table_output like 'Plan%';
    
    plan_hash_value := to_number(substr(planoutput,18));
  EXCEPTION
    WHEN others THEN
      DBMS_OUTPUT.put_line('Error getting plan in update_explain_plan_hash on SQL number '||v_sqlnumber);
      DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
      plan_hash_value := 0;
  end;

  select count(*) into row_cnt
  from test_results t
  where 
  t.test_name=v_test_name and
  t.sqlnumber=v_sqlnumber;
  
  if row_cnt > 0 then
    update test_results t
    set explain_plan_hash=plan_hash_value
    where 
      t.test_name=v_test_name and
      t.sqlnumber=v_sqlnumber;
  else
    insert into test_results 
    (test_name,sqlnumber,explain_plan_hash)
    values (
      v_test_name,
      v_sqlnumber,
      plan_hash_value);
  end if;
  commit;
 
 
end update_explain_plan_hash;

procedure get_explain_plans(
test_name in varchar2) 
 is
    CURSOR SQL_CURSOR IS 
        SELECT  
            sqlnumber,
            sql_text
        FROM select_statements
        ORDER by sqlnumber;
    SQL_REC SQL_CURSOR%ROWTYPE;
    clob_cursor INTEGER;
    sqlclob clob;
    ignored_value INTEGER;

begin
 
    execute immediate 'delete from plan_table where statement_id like '''||test_name||'%''';
    
    commit;

    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;
        
        sqlclob := 'explain plan set statement_id = '''||test_name||SQL_REC.sqlnumber||''' into plan_table for '||
                   SQL_REC.sql_text;

        begin
          clob_cursor := DBMS_SQL.OPEN_CURSOR;
          DBMS_SQL.PARSE (clob_cursor,sqlclob,DBMS_SQL.NATIVE);
          ignored_value := DBMS_SQL.EXECUTE(clob_cursor);
          DBMS_SQL.CLOSE_CURSOR (clob_cursor);
          update_explain_plan_hash(test_name,SQL_REC.sqlnumber);
          DBMS_OUTPUT.put_line('Plan explained for SQL number '||SQL_REC.sqlnumber);
          
        EXCEPTION
          WHEN others THEN
	    DBMS_OUTPUT.put_line('Error on SQL number '||SQL_REC.sqlnumber);
	    DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
	    update_error(test_name,SQL_REC.sqlnumber,SQLERRM);
        end;
        commit;
     END LOOP;
    CLOSE SQL_CURSOR;

end get_explain_plans;

procedure runselect(
       v_test_name in varchar2,
       v_sqlnumber in number,
       sqlclob  in clob) is
    clob_cursor INTEGER;
    rows_fetched INTEGER;
    before_date date;
    after_date date;
    total_rows_fetched NUMBER;
    elapsed_time_seconds NUMBER;
    row_cnt number;
    query_sql_id varchar2(13);
    planoutput clob;
    plan_hash_value number;
    cursor_child_no number;
    
    b_CPU_used_by_this_session number;
    b_consistent_gets number;
    b_db_block_gets number;
    b_parse_time_elapsed number;
    b_physical_reads number;
    b_user_commits number;
    b_db_block_changes number;

    a_CPU_used_by_this_session number;
    a_consistent_gets number;
    a_db_block_gets number;
    a_parse_time_elapsed number;
    a_physical_reads number;
    a_user_commits number;
    a_db_block_changes number;

    v_dummy varchar2(1);

BEGIN
    select sysdate into before_date from dual;
    
-- record current values of session statistics

    select
    max(s1.value) CPU_used_by_this_session,
    max(s2.value) consistent_gets,
    max(s3.value) db_block_gets,
    max(s4.value) parse_time_elapsed,
    max(s5.value) physical_reads,
    max(s6.value) user_commits,
    max(s7.value) db_block_changes
    into
    b_CPU_used_by_this_session,
    b_consistent_gets,
    b_db_block_gets,
    b_parse_time_elapsed,
    b_physical_reads,
    b_user_commits,
    b_db_block_changes
    from 
    v$mystat s1, 
    v$mystat s2, 
    v$mystat s3, 
    v$mystat s4, 
    v$mystat s5, 
    v$mystat s6, 
    v$mystat s7, 
    V$STATNAME n1,
    V$STATNAME n2,
    V$STATNAME n3,
    V$STATNAME n4,
    V$STATNAME n5,
    V$STATNAME n6,
    V$STATNAME n7
    where
    s1.STATISTIC#=n1.STATISTIC# and
    n1.name = 'CPU used by this session' and
    s2.STATISTIC#=n2.STATISTIC# and
    n2.name = 'consistent gets' and
    s3.STATISTIC#=n3.STATISTIC# and
    n3.name = 'db block gets' and
    s4.STATISTIC#=n4.STATISTIC# and
    n4.name = 'parse time elapsed' and
    s5.STATISTIC#=n5.STATISTIC# and
    n5.name = 'physical reads' and
    s6.STATISTIC#=n6.STATISTIC# and
    n6.name = 'user commits' and
    s7.STATISTIC#=n7.STATISTIC# and
    n7.name = 'db block changes';
        
    clob_cursor := DBMS_SQL.OPEN_CURSOR;
    
    DBMS_SQL.PARSE (clob_cursor,sqlclob,DBMS_SQL.NATIVE);
    
    DBMS_SQL.DEFINE_COLUMN(clob_cursor,1,v_dummy,1);
    
    rows_fetched := DBMS_SQL.EXECUTE_AND_FETCH (clob_cursor);
    total_rows_fetched := rows_fetched;
  
    LOOP
        EXIT WHEN rows_fetched < 1;
        rows_fetched := DBMS_SQL.FETCH_ROWS (clob_cursor);
        total_rows_fetched := total_rows_fetched + rows_fetched;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR (clob_cursor);
    
    SELECT PREV_SQL_ID,PREV_CHILD_NUMBER 
    INTO QUERY_SQL_ID,CURSOR_CHILD_NO
    FROM
    (SELECT ROWNUM RN,PREV_SQL_ID,PREV_CHILD_NUMBER 
    FROM V$SESSION 
    WHERE AUDSID=USERENV('SESSIONID'))
    WHERE RN = 1;
   
-- record current values of session statistics

    select
    max(s1.value) CPU_used_by_this_session,
    max(s2.value) consistent_gets,
    max(s3.value) db_block_gets,
    max(s4.value) parse_time_elapsed,
    max(s5.value) physical_reads,
    max(s6.value) user_commits,
    max(s7.value) db_block_changes
    into
    a_CPU_used_by_this_session,
    a_consistent_gets,
    a_db_block_gets,
    a_parse_time_elapsed,
    a_physical_reads,
    a_user_commits,
    a_db_block_changes
    from 
    v$mystat s1, 
    v$mystat s2, 
    v$mystat s3, 
    v$mystat s4, 
    v$mystat s5, 
    v$mystat s6, 
    v$mystat s7, 
    V$STATNAME n1,
    V$STATNAME n2,
    V$STATNAME n3,
    V$STATNAME n4,
    V$STATNAME n5,
    V$STATNAME n6,
    V$STATNAME n7
    where
    s1.STATISTIC#=n1.STATISTIC# and
    n1.name = 'CPU used by this session' and
    s2.STATISTIC#=n2.STATISTIC# and
    n2.name = 'consistent gets' and
    s3.STATISTIC#=n3.STATISTIC# and
    n3.name = 'db block gets' and
    s4.STATISTIC#=n4.STATISTIC# and
    n4.name = 'parse time elapsed' and
    s5.STATISTIC#=n5.STATISTIC# and
    n5.name = 'physical reads' and
    s6.STATISTIC#=n6.STATISTIC# and
    n6.name = 'user commits' and
    s7.STATISTIC#=n7.STATISTIC# and
    n7.name = 'db block changes';
    
-- check for failed explain plan - 0 plan_hash_value

    begin
      select t.PLAN_TABLE_OUTPUT 
      into planoutput 
      from table(dbms_xplan.display_cursor(query_sql_id,cursor_child_no,'BASIC')) t
      where t.plan_table_output like 'Plan%';
    
      plan_hash_value:=to_number(substr(planoutput,18));
    EXCEPTION
      WHEN others THEN
        DBMS_OUTPUT.put_line('Error getting plan in runselect on SQL number '||v_sqlnumber);
        DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
        plan_hash_value := 0;
    end;
                
    select sysdate into after_date from dual;
    
    elapsed_time_seconds := (after_date-before_date)*24*3600;
    
    rollback;
    
    select count(*) into row_cnt
    from test_results t
    where 
    t.test_name=v_test_name and
    t.sqlnumber=v_sqlnumber;
    
    if row_cnt > 0 then
      update test_results t
      set 
        rows_fetched=total_rows_fetched,
        elapsed_in_seconds=elapsed_time_seconds,
        sql_id=query_sql_id,
        execute_plan_hash=plan_hash_value,
        CPU_used_by_this_session=a_CPU_used_by_this_session-b_CPU_used_by_this_session,
        consistent_gets=a_consistent_gets-b_consistent_gets,
        db_block_gets=a_db_block_gets-b_db_block_gets,
        parse_time_elapsed=a_parse_time_elapsed-b_parse_time_elapsed,
        physical_reads=a_physical_reads-b_physical_reads,
        user_commits=a_user_commits-b_user_commits,
        db_block_changes=a_db_block_changes-b_db_block_changes
      where 
        t.test_name=v_test_name and
        t.sqlnumber=v_sqlnumber;
    else
      insert into test_results 
      (test_name,sqlnumber,rows_fetched,elapsed_in_seconds,sql_id,execute_plan_hash,
       CPU_used_by_this_session,consistent_gets,db_block_gets,parse_time_elapsed,
       physical_reads,user_commits,db_block_changes)
      values (
        v_test_name,
        v_sqlnumber,
        total_rows_fetched,
        elapsed_time_seconds,
        query_sql_id,
        plan_hash_value,
        a_CPU_used_by_this_session-b_CPU_used_by_this_session,
        a_consistent_gets-b_consistent_gets,
        a_db_block_gets-b_db_block_gets,
        a_parse_time_elapsed-b_parse_time_elapsed,
        a_physical_reads-b_physical_reads,
        a_user_commits-b_user_commits,
        a_db_block_changes-b_db_block_changes);
    end if;
    
    commit;

END runselect;

procedure execute_all(
test_name in varchar2) 
 is
    CURSOR SQL_CURSOR IS 
        SELECT  
            sqlnumber,
            sql_text
        FROM select_statements
        ORDER by sqlnumber;
    SQL_REC SQL_CURSOR%ROWTYPE;

begin
 
    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;

        begin
          runselect(test_name,
	         SQL_REC.sqlnumber,
	         SQL_REC.sql_text);

          DBMS_OUTPUT.put_line('Executed SQL number '||SQL_REC.sqlnumber);
          
        EXCEPTION
          WHEN others THEN
	    DBMS_OUTPUT.put_line('Error on SQL number '||SQL_REC.sqlnumber);
	    DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
	    update_error(test_name,SQL_REC.sqlnumber,SQLERRM);
        end;
        commit;
     END LOOP;
    CLOSE SQL_CURSOR;

end execute_all;

procedure execute_diff_plans(
   v_test_name in varchar2,
   compared_to_test_name in varchar2) 
 is
    CURSOR SQL_CURSOR IS 
        SELECT  
            sqlnumber,
            sql_text
        FROM select_statements
        ORDER by sqlnumber;
    SQL_REC SQL_CURSOR%ROWTYPE;
    row_cnt number;

begin
 
    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;
        
        select count(*) into row_cnt
        from test_results t1,test_results t2
        where 
        t1.explain_plan_hash <> t2.explain_plan_hash and
        t1.test_name=v_test_name and
        t2.test_name=compared_to_test_name and
        t1.sqlnumber=SQL_REC.sqlnumber and
        t1.sqlnumber=t2.sqlnumber;
        
        if row_cnt > 0 then

          begin
            runselect(v_test_name,
	           SQL_REC.sqlnumber,
	           SQL_REC.sql_text);
  
            DBMS_OUTPUT.put_line('Executed SQL number '||SQL_REC.sqlnumber);
            
          EXCEPTION
            WHEN others THEN
	      DBMS_OUTPUT.put_line('Error on SQL number '||SQL_REC.sqlnumber);
	      DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
	      update_error(v_test_name,SQL_REC.sqlnumber,SQLERRM);
          end;
          commit;
          
        end if;
     END LOOP;
    CLOSE SQL_CURSOR;

end execute_diff_plans;

procedure display_results(
   v_test_name in varchar2,
   compared_to_test_name in varchar2) 
 is
    CURSOR RSLT_CURSOR(TEST1 varchar2,TEST2 varchar2) IS 
       select
       t1.SQLNUMBER,
       t1.SQL_ID,
       t1.EXPLAIN_PLAN_HASH T1_EXPLAIN_PLAN_HASH,
       t1.EXECUTE_PLAN_HASH T1_EXECUTE_PLAN_HASH,
       t2.EXPLAIN_PLAN_HASH T2_EXPLAIN_PLAN_HASH,
       t2.EXECUTE_PLAN_HASH T2_EXECUTE_PLAN_HASH,
       t1.ELAPSED_IN_SECONDS T1_ELAPSED_IN_SECONDS,
       t2.ELAPSED_IN_SECONDS T2_ELAPSED_IN_SECONDS
       from
       test_results t1,
       test_results t2
       where
       t1.SQLNUMBER=t2.SQLNUMBER and
       t1.TEST_NAME=TEST1 and
       t2.TEST_NAME=TEST2 and
       (t1.ELAPSED_IN_SECONDS*3) < t2.ELAPSED_IN_SECONDS and
       t1.ELAPSED_IN_SECONDS is not null and
       t2.ELAPSED_IN_SECONDS is not null
       order by sqlnumber;

    RSLT_REC RSLT_CURSOR%ROWTYPE;
    
    row_cnt number;
    
    t1_elapsed number;
    t1_count number;
    t1_average number;
    
    t2_elapsed number;
    t2_count number;
    t2_average number;

begin

-- output selects where test1 3 times better than test2

    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Select statements that ran 3 times faster with '||
        v_test_name||' than with '||compared_to_test_name||'.');
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('T1='||v_test_name);
    DBMS_OUTPUT.PUT_LINE('T2='||compared_to_test_name);
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'SQLNUMBER T1_EXECUTE_PLAN_HASH T2_EXECUTE_PLAN_HASH T1_ELAPSED_IN_SECONDS T2_ELAPSED_IN_SECONDS');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'--------- -------------------- -------------------- --------------------- ---------------------');

    row_cnt := 0;

    OPEN RSLT_CURSOR(v_test_name,compared_to_test_name);
    LOOP
        FETCH RSLT_CURSOR INTO RSLT_REC;
        EXIT WHEN RSLT_CURSOR%NOTFOUND;
        row_cnt := row_cnt + 1;
        DBMS_OUTPUT.PUT_LINE(CHR(9)||
          lpad(to_char(RSLT_REC.SQLNUMBER),9)||' '||
          lpad(to_char(RSLT_REC.T1_EXECUTE_PLAN_HASH),20)||' '||
          lpad(to_char(RSLT_REC.T2_EXECUTE_PLAN_HASH),20)||' '||
          lpad(TO_CHAR(trunc(RSLT_REC.T1_ELAPSED_IN_SECONDS)),21)||' '||
          lpad(TO_CHAR(trunc(RSLT_REC.T2_ELAPSED_IN_SECONDS)),21));
     END LOOP;
    CLOSE RSLT_CURSOR;
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Number of selects='||to_char(row_cnt));
    
-- output selects where test2 3 times better than test1

    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Select statements that ran 3 times faster with '||
        compared_to_test_name||' than with '||v_test_name||'.');
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('T1='||compared_to_test_name);
    DBMS_OUTPUT.PUT_LINE('T2='||v_test_name);
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'SQLNUMBER T1_EXECUTE_PLAN_HASH T2_EXECUTE_PLAN_HASH T1_ELAPSED_IN_SECONDS T2_ELAPSED_IN_SECONDS');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'--------- -------------------- -------------------- --------------------- ---------------------');

    row_cnt := 0;

    OPEN RSLT_CURSOR(compared_to_test_name,v_test_name);
    LOOP
        FETCH RSLT_CURSOR INTO RSLT_REC;
        EXIT WHEN RSLT_CURSOR%NOTFOUND;
        row_cnt := row_cnt + 1;
        DBMS_OUTPUT.PUT_LINE(CHR(9)||
          lpad(to_char(RSLT_REC.SQLNUMBER),9)||' '||
          lpad(to_char(RSLT_REC.T1_EXECUTE_PLAN_HASH),20)||' '||
          lpad(to_char(RSLT_REC.T2_EXECUTE_PLAN_HASH),20)||' '||
          lpad(TO_CHAR(trunc(RSLT_REC.T1_ELAPSED_IN_SECONDS)),21)||' '||
          lpad(TO_CHAR(trunc(RSLT_REC.T2_ELAPSED_IN_SECONDS)),21));
     END LOOP;
    CLOSE RSLT_CURSOR;
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Number of selects='||to_char(row_cnt));
    
    -- summary results 
        
    select
    sum(t1.ELAPSED_IN_SECONDS),
    count(*),
    sum(t1.ELAPSED_IN_SECONDS)/count(*),
    sum(t2.ELAPSED_IN_SECONDS),
    sum(t2.ELAPSED_IN_SECONDS)/count(*)
    into
    t1_elapsed,
    t1_count,
    t1_average,
    t2_elapsed,
    t2_average
    from
    test_results t1,
    test_results t2
    where
    t1.SQLNUMBER=t2.SQLNUMBER and
    t1.TEST_NAME=v_test_name and
    t2.TEST_NAME=compared_to_test_name and
    t1.ELAPSED_IN_SECONDS is not null and
    t2.ELAPSED_IN_SECONDS is not null;
    
    t2_count := t1_count;
    
    DBMS_OUTPUT.PUT_LINE(CHR(9));
    DBMS_OUTPUT.PUT_LINE('Summary of test results');
    DBMS_OUTPUT.PUT_LINE(CHR(9));    
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'           TEST_NAME TOTAL_ELAPSED_IN_SECONDS SELECTS_EXECUTED AVERAGE_ELAPSED_IN_SECONDS');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'-------------------- ------------------------ ---------------- --------------------------');

    DBMS_OUTPUT.PUT_LINE(CHR(9)||
       lpad(v_test_name,20)||' '||
       lpad(to_char(t1_elapsed),24)||' '||
       lpad(to_char(t1_count),16)||' '||
       lpad(TO_CHAR(trunc(t1_average)),26));

    DBMS_OUTPUT.PUT_LINE(CHR(9)||
       lpad(compared_to_test_name,20)||' '||
       lpad(to_char(t2_elapsed),24)||' '||
       lpad(to_char(t2_count),16)||' '||
       lpad(TO_CHAR(trunc(t2_average)),26));

end display_results;

function show_explained_plan(
   v_test_name in varchar2,
   sqlnumber in number) return CLOB
is
begin

return dbms_xplan.display_plan('PLAN_TABLE',v_test_name||to_char(sqlnumber),'ALL');

end show_explained_plan;

procedure reexecute_errored(
v_test_name in varchar2) 
 is
    CURSOR SQL_CURSOR IS 
        SELECT  
            s.sqlnumber,
            s.sql_text
        FROM 
            select_statements s,
            test_results t
        WHERE
            s.sqlnumber=t.sqlnumber and
            t.error_message is not null and
            t.test_name = v_test_name
        ORDER by sqlnumber;
    SQL_REC SQL_CURSOR%ROWTYPE;

begin
 
    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;
        
        update test_results t
        set t.error_message=NULL
        where 
        t.sqlnumber=SQL_REC.sqlnumber and
        t.test_name=v_test_name;
        
        commit;

        begin
          runselect(v_test_name,
	         SQL_REC.sqlnumber,
	         SQL_REC.sql_text);

          DBMS_OUTPUT.put_line('Executed SQL number '||SQL_REC.sqlnumber);
          
        EXCEPTION
          WHEN others THEN
	    DBMS_OUTPUT.put_line('Error on SQL number '||SQL_REC.sqlnumber);
	    DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
	    update_error(v_test_name,SQL_REC.sqlnumber,SQLERRM);
        end;
        commit;
     END LOOP;
    CLOSE SQL_CURSOR;

end reexecute_errored;

procedure show_executed_plan(
   v_test_name in varchar2,
   v_sqlnumber in number)
is
    CURSOR SQL_CURSOR IS 
      select
      SQL_ID,
      EXECUTE_PLAN_HASH
      from 
      test_results 
      where 
      sqlnumber=v_sqlnumber and
      TEST_NAME=v_test_name;
    SQL_REC SQL_CURSOR%ROWTYPE;
    
    CURSOR SQL_CURSOR2(p_sql_id varchar2,p_plan_hash number)
      IS 
      select PLAN_TABLE_OUTPUT from
         table(DBMS_XPLAN.DISPLAY_AWR(p_sql_id,
         p_plan_hash,
         NULL,
         'ALL'));
    SQL_REC2 SQL_CURSOR2%ROWTYPE;
    
begin

    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;
        
        OPEN SQL_CURSOR2(SQL_REC.SQL_ID,SQL_REC.EXECUTE_PLAN_HASH);
 
        LOOP
           FETCH SQL_CURSOR2 INTO SQL_REC2;
           EXIT WHEN SQL_CURSOR2%NOTFOUND;

           DBMS_OUTPUT.put_line(SQL_REC2.PLAN_TABLE_OUTPUT);
        END LOOP;
          
     END LOOP;
    CLOSE SQL_CURSOR;

end show_executed_plan;

procedure execute_one(
v_test_name in varchar2,
v_sqlnumber in number) 
is
    CURSOR SQL_CURSOR IS 
        SELECT  
            s.sqlnumber,
            s.sql_text
        FROM 
            select_statements s,
            test_results t
        WHERE
            s.sqlnumber=t.sqlnumber and
            s.sqlnumber = v_sqlnumber and
            t.test_name = v_test_name
        ORDER by sqlnumber;
    SQL_REC SQL_CURSOR%ROWTYPE;

begin
 
    OPEN SQL_CURSOR;
    LOOP
        FETCH SQL_CURSOR INTO SQL_REC;
        EXIT WHEN SQL_CURSOR%NOTFOUND;
        
        update test_results t
        set t.error_message=NULL
        where 
        t.sqlnumber=SQL_REC.sqlnumber and
        t.test_name=v_test_name;
        
        commit;

        begin
          runselect(v_test_name,
                 SQL_REC.sqlnumber,
                 SQL_REC.sql_text);

          DBMS_OUTPUT.put_line('Executed SQL number '||SQL_REC.sqlnumber);
          
        EXCEPTION
          WHEN others THEN
            DBMS_OUTPUT.put_line('Error on SQL number '||SQL_REC.sqlnumber);
            DBMS_OUTPUT.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
            update_error(v_test_name,SQL_REC.sqlnumber,SQLERRM);
        end;
        commit;
     END LOOP;
    CLOSE SQL_CURSOR;

end execute_one;

end TEST_SELECT;
/
show errors
