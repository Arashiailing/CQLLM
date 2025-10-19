import python

/**
 * This query detects potential HTTP header injection vulnerabilities.
 * It looks for cases where user input is directly used in HTTP headers.
 */

from Call call, Expr userInput, Expr header
where call.getCallee().getName() = "set_header"
  and call.getArgument(0) = header
  and userInput instanceof UserInput
  and call.getArgument(1) = userInput
select call, "Potential HTTP header injection vulnerability detected. User input is directly used in HTTP headers."