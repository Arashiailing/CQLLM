import python

/**
 * This query detects potential CWE-94: Code Injection vulnerabilities
 * by identifying cases where user input is directly used in an eval call.
 */
from Call call, Expr userInput
where call.getCallee().getName() = "eval" and
      call.getArgument(0) = userInput and
      userInput instanceof UserInput
select call, "Potential code injection vulnerability: User input is directly used in an eval call."