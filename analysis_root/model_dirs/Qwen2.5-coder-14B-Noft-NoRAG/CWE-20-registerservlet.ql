import java

/**
 * Detects potential SQL injection vulnerabilities in Java code.
 */
from Call call, StringLiteral sqlQuery
where call.getCallee().getName() = "executeQuery"
  and call.getArgument(0) = sqlQuery
select call, sqlQuery, "Potential SQL injection vulnerability detected in SQL query: " + sqlQuery.getValue()