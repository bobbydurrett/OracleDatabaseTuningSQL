sqlplus %1/%2@%3 @tablelist.sql
sqlplus -s %1/%2@%3 @makeexp.sql %1 %2
sqlplus -s %1/%2@%3 @makebefore.sql %1 %2
sqlplus -s %1/%2@%3 @makeallimp.sql %1 %2
sqlplus -s %1/%2@%3 @makeafter.sql %1 %2
