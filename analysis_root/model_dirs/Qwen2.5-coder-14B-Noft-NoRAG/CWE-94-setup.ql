import python

/**
 * This query detects potential code injection vulnerabilities in Python code.
 * It looks for instances where user input is directly used in an exec or eval statement.
 */

from Call call, StringLiteral input
where call.getCallee().getName() = "exec" or call.getCallee().getName() = "eval"
  and call.getArgument(0) = input
select call, "Potentially vulnerable exec or eval call with user input."