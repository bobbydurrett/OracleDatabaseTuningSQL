drop table select_statements;

create table select_statements 
(sqlnumber number, 
sql_text clob);

create unique index select_statements_i1 on select_statements(sqlnumber);

drop table test_results;

create table test_results 
(test_name varchar2(2000),
sqlnumber number,
sql_id VARCHAR2(13),
explain_plan_hash number,
execute_plan_hash number,
rows_fetched number,
elapsed_in_seconds number,
CPU_used_by_this_session number,
consistent_gets number,
db_block_gets number,
parse_time_elapsed number,
physical_reads number,
user_commits number,
db_block_changes number,
error_message varchar2(64));

create unique index test_results_i1 on test_results(test_name,sqlnumber);
create index test_results_i2 on test_results(sqlnumber);
