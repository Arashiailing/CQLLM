import python
import semmle.code.cpp.security.Cwe522

from MethodCall mc, StringLiteral sl
where 
  mc.getMethodName() = "write" and 
  mc.getArgument(0) = sl and 
  sl.getValue().matches(".*password.*") or 
  sl.getValue().matches(".*secret.*") or 
  sl.getValue().matches(".*key.*")
select mc, "Potential CWE-522: Sensitive information stored in cleartext"