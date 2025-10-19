import python

/**
 * @name CWE-89: SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of malicious SQL code by the user.
 * @id py/victim
 */

from FunctionCall fc, Expr userControlledSource, Expr sqlQuery
where fc.getCallee().getName() = "execute" or fc.getCallee().getName() = "executemany"
  and userControlledSource = fc.getArgument(0)
  and sqlQuery = fc.getArgument(1)
select sqlQuery, "This SQL query is built from user-controlled sources, which is vulnerable to SQL injection."