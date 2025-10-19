import python
import semmle.code.cpp.arraysandpointers
import semmle.code.scala.controlflow

from CommandExecutionFunction call, Parameter param, StringLiteral stringLit
where call.getParameters().contains(param) and
      param.getValue().getStringValue() = stringLit.getStringValue() and
      call.isCommandExecutionFunction() and
      stringLit.getKind() = "FormatString" and
      exists(Argument arg | arg.getExpression() = param.getValue())
select call, "Potential Command Injection vulnerability via format string argument"

import python

/** @predicate */
predicate isCommandExecutionFunction(Function f) {
  f.getName() = "subprocess.run" or
                f.getName() = "subprocess.call" or
                f.getName() = "subprocess.check_call" or
                f.getName() = "subprocess.check_output" or
                f.getName() = "os.system" or
                f.getName() = "shlex.split" or
                f.getName() = "commands.getoutput"
}

from Call call, Argument arg, Expression expr
where call.getCallee().getFunction().isCommandExecutionFunction() and
      arg.getArgumentIndex() = 0 and
      expr instanceof StringLiteral and
      exists(Variable v | v.isUserInput() and v.getUsage().getExpression() = expr)
select call, "Potential Command Injection vulnerability detected"