import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/ZRPythonExpr
 */
from Call c, StringLiteral sl, Variable v
where 
    c.getCallee().getName() = "print" and 
    sl.getValue() = "Hello, %s!" and 
    c.getArg(0) = v and 
    (v.getSource().getName() = "request" or v.getSource().getName() = "params")
select c, "Potential reflected XSS due to direct output of unescaped user input."