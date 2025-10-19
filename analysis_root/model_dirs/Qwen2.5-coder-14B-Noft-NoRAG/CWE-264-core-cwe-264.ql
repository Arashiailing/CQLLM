import python

/**
 * CWE-264: Command Injection
 * This query detects potential command injection vulnerabilities in Python code.
 * It looks for subprocess calls where user input is directly included in the command string.
 */

from Call call, StringLiteral literal, Expr userInput
where call.getCallee().getName() = "subprocess.call"
  and call.getArgument(0) = literal
  and literal.hasSubtree(userInput)
select call, "Potential command injection vulnerability detected. User input is directly included in the command string."