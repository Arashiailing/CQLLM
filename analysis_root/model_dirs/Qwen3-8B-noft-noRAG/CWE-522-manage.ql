import python

/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Detects storage of credentials in cleartext.
 */
from MethodCall mc, StringLiteral sl
where 
  mc.getMethodName() = "write" and 
  mc.getArgument(0).getValue().toString() = sl.getValue() and 
  sl.getValue().contains("password") or 
  sl.getValue().contains("secret") or 
  sl.getValue().contains("token")
select sl, "Potential CWE-522: Credential stored in cleartext"