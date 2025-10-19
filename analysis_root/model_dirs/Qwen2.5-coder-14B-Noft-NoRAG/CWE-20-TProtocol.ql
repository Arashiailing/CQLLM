import python

/**
 * CWE-20: Improper Input Validation
 * This query detects potential code injection vulnerabilities
 * by looking for unsafe uses of user input in command execution.
 */

from Command cmd, Expr input
where cmd.getArgument(0) = input and
      input instanceof UserInput
select cmd, "This command may be vulnerable to code injection due to improper input validation."