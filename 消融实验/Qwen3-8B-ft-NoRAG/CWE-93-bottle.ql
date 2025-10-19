import python
import semmle.code.cpp.dataflow.DataFlow

from MethodCall mc, StringLiteral crlf, StringLiteral crlf2
where 
  mc.getMethodName() = "set_header" or 
  mc.getMethodName() = "headers" and 
  mc.getArg(0).getValue() = crlf and 
  crlf.getValue() = "\r\n" or 
  mc.getArg(0).getValue() = crlf2 and 
  crlf2.getValue() = "\r\n"
select mc, "Potential CRLF injection in HTTP header value"