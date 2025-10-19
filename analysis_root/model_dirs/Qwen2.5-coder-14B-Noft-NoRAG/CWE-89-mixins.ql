import python

/**
 * A query to detect CWE-89: SQL Injection.
 * This query looks for SQL queries that are constructed using user-controlled input.
 */

from Call call, DataFlow::Node userInput, DataFlow::Node sqlQuery
where call.getCallee().getName() = "execute" and
      DataFlow::localFlow(userInput, sqlQuery) and
      sqlQuery instanceof Expr
select call, "This SQL query is constructed using user-controlled input, which is vulnerable to SQL injection."