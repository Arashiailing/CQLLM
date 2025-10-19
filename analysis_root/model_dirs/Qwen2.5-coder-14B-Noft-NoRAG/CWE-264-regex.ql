import python

/**
 * This query detects CWE-264: Regex Injection vulnerability.
 * CWE-264 occurs when user input is used to construct a regular expression without proper validation.
 */

from Call call, Arg arg
where call.getCallee().getName() = "re.compile" and
      arg = call.getArgument(0) and
      arg instanceof StringLiteral
select arg, "User input is used to construct a regular expression without proper validation."