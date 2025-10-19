import python

/**
 * @name CWE-89: SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of malicious SQL code by the user.
 * @id py/stats
 */

from MethodCall call, Parameter param
where 
  (call.getMethodName() = "format" or call.getMethodName() = "format_map") and
  call.getArgument(0).getValue().getSymbol().getName() = "sql_query" and
  exists(Anchor anchor | anchor.getValue().getSymbol().getName() = "user_input")
select call, "Potential SQL injection vulnerability: User-controlled input used in SQL query construction"

import python

from CallSite site, StringLiteral sqlLit, Variable userInput
where 
  site.getCallee().getName() = "execute" and
  site.getArgument(0) = sqlLit and
  exists(Anchor anchor | anchor.getValue().getSymbol().getName() = userInput.getName() and
         anchor.getLocation() instanceof Parameter and
         anchor.getLocation().getVariable().getName() = userInput.getName())
select site, "SQL injection vulnerability detected: User input directly embedded in SQL query"