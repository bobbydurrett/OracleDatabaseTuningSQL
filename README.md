# OracleDatabaseTuningSQL

These are the [SQL](https://en.wikipedia.org/wiki/SQL) scripts that Bobby Durrett uses for [Oracle](https://www.oracle.com/index.html)
database performance tuning. 

These scripts are designed to be run through Oracle's [SQL\*Plus](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/index.html) utility.

So, if you have a script called `example.sql` you would run it like this in
SQL\*Plus:

`sqlplus myuser/mypassword@mydatabase < example.sql`

## Directories:

* `ash` - Active Session History related

* `awr` - Automatic Workload Repository related

* `force_matching_signature` - Queries that use force_matching_signature

* `misc` - Queries that don't fall into another category

* `optimizerstatistics` - Values that the optimizer uses

* `perfprofile` - Performance profiles from V$ tables

* `plan` - Scripts to show a query plan

* `refresh` - Refresh tables using export and import

* `resourcemanager` - Resource manager queries

* `spaceproddbs` - Space and related queries

* `testselectpackage` - Package to extract and test select statements

* `v$` - Scripts that use the v$ views

Bobby Durrett

Blog: http://www.bobbydurrettdba.com/

