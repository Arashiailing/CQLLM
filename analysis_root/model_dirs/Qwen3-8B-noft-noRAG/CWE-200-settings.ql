import semmle.python.security.dataflow.PythonDataFlow
import semmle.code.cpp.querying.PyCall

from PrintStatement ps, StringLiteral sl
where ps.getArgument(0) = sl and sl.getValue() matches /.*(?:password|key|secret|token|cred|credentials).*/i
select ps, "Potential exposure of sensitive information in a print statement."

from LogMessage lm, StringLiteral sl
where lm.getMessage() = sl and sl.getValue() matches /.*(?:password|key|secret|token|cred|credentials).*/i
select lm, "Potential exposure of sensitive information in a log message."

from PyFunctionCall call, PyVariable var
where call.getMethodName() = "error" or call.getMethodName() = "exception" 
  and call.getArgument(0) = var 
  and (var.getName() matches /.*password.*/i or var.getName() matches /.*key.*/i)
select call, "Potential exposure of sensitive information in exception handling."