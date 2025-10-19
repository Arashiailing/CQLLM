import python

from MethodCall call
where 
  (call.getMethod().getName() = "get" or call.getMethod().getName() = "post") 
  and call.getContainingType().getName() = "requests.sessions.Session"
  and exists(Param p | p.getDeclaringMethod() = call.getMethod() and p.getName() = "verify" and p.getValueLiteral() = "False")
select call, "Potential CWE-295: Improper Certificate Validation - SSL verification disabled explicitly"