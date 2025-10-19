import python

/**
 * This query detects potential Command Injection vulnerabilities in Python code.
 * It looks for cases where user input is directly used to construct a command
 * that is then executed.
 */

from Call call, StringLiteral cmd, Argument arg
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.run" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen" or
      call.getCallee().getName() = "os.startfile"
  and call.getArgument(0) = cmd
  and arg = call.getArgument(0)
  and arg.getExpr() instanceof ExternalArgument
select cmd, "This command is constructed using user input, which may lead to Command Injection."