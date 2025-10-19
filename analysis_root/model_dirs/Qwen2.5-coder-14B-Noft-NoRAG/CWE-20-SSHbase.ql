import python

/**
 * This query detects potential command injection vulnerabilities
 * by identifying cases where user input is directly passed to a
 * shell command without proper validation.
 */

from Call call, Expr userInput, Expr cmdExpr
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.run" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and call.getArgument(0) = userInput
  and not exists(Expr validation | validation.getAChild() = userInput)
select call, "Potentially vulnerable to command injection due to unvalidated user input."