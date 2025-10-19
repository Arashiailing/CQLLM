import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.python.security.CommandInjection

from CallExpr call, StringLiteral cmdStr, Variable var
where call.getMethod().getName() = "subprocess.Popen" or
      call.getMethod().getName() = "subprocess.call" or
      call.getMethod().getName() = "subprocess.run" or
      call.getMethod().getName() = "os.system"
    and exists(Argument arg |
       call.getArgs() = arg and
       arg.getValue() = cmdStr and
       cmdStr.getStringValue() = var.getName())
    and not (var.getType().getFullyQualifiedName() = "builtins.str" and var.isConstant())
select var, "Potential command injection vulnerability due to unvalidated user input in command execution."