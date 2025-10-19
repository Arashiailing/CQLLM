import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/victim
 */
from MethodInvocation mi, StringLiteral sl, Parameter p
where 
    mi.getMethod().getName() = "print" and
    mi.getArgument(0).getValue().matches(p) and
    p.getValue().getUsages().hasUserInput()
select mi.getLocation(), "Potential reflected XSS vulnerability: User input is directly output to the web page."