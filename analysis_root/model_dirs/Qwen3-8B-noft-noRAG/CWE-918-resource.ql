import py

/**
 * Detects potential SSRF vulnerabilities by identifying network requests
 * that use user-controllable input in their URLs without proper validation.
 */
from method m, Call c, Argument arg
where 
  m.name = "get" and 
  c.getTarget() = m and 
  arg.getValue().hasText("url") and 
  arg.getValue().getExpression().isVariable()
select c, "Potential SSRF vulnerability: Unvalidated URL parameter used in network request."