import python
import semmle.code.cpp.dataflow.DataFlow

from CallExpr call, StringLiteral arg, Argument args
where 
  call.getMethodName() = "os.system" or 
  call.getMethodName() = "open" or 
  call.getMethodName() = "subprocess.run"
  and args.getArgument(0) = arg
  and arg.getValue().matches(".*\$$[^$]*\$$")
select call, "Potential CWE-59 vulnerability: Improper link resolution in file access"