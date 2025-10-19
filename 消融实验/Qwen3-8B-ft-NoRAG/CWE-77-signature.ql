import python
import semmle.code.cpp.dataflow.DataFlow

from CommandExecutionFunction call, Argument arg, InputSource input
where call.getArgument(0).equals(arg) and
      arg.getArgumentValue().contains(input) and
      call.getFunction().getName().matches("subprocess\\.run|subprocess\\.call|subprocess\\.check_output|os\\.system|os\\.popen") and
      (call.getFunction().getName().matches("subprocess\\.run|subprocess\\.call|subprocess\\.check_output") and call.getArgument(1).getArgumentValue().isString() or
       call.getFunction().getName().matches("os\\.system|os\\.popen") and call.getArgument(0).getArgumentValue().isString()) and
      (call.getFunction().getName().matches("subprocess\\.run|subprocess\\.call|subprocess\\.check_output") and call.getArgument(2).getArgumentValue().isString() and call.getArgument(2).getArgumentValue().getValue().equals("shell") and call.getArgument(2).getArgumentValue().getValue().equals("True") or
       call.getFunction().getName().matches("os\\.system|os\\.popen") and call.getArgument(0).getArgumentValue().getValue().contains("shell=True"))
select call, "Potential Command Injection vulnerability: Command is constructed with user input and shell=True or not parameterized properly."