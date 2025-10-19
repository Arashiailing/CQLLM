import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.security.UrlRedirection

from HttpModule httpModule, MethodCall methodCall, StringLiteral input
where 
  methodCall.getTarget() = httpModule.getMethod("setLocation") and
  methodCall.getArgument(0) = input and
  input.getKind() = "userInput"
select methodCall, "Potential URL redirection based on unvalidated user input (CWE-601)"