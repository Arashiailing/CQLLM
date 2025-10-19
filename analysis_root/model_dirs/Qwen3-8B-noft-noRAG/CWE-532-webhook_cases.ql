import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.python.LogCall

from LogCall logCall, StringLiteral stringLit, Parameter param
where 
  logCall.getMessage().getArgument(0).isStringLiteral() and 
  stringLit.getValue().matches(/.*(?:password|secret|token|key|cred|auth).*$/) or
  (logCall.getMessage().getNumArguments() > 0 and 
   logCall.getMessage().getArgument(0).isParameter() and 
   param.getName().matches(/.*(?:password|secret|token|key|cred|auth).*$/))
select logCall.getLocation(), "Potential sensitive information logged: " + logCall.getMessage().getValue()