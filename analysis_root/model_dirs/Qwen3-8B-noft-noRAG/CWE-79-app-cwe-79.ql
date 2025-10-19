import python
import semmle.code.scala.compiler.Expressions

/**
 * Detects potential reflected XSS by finding instances where user-controlled data
 * is directly written to HTTP responses without proper escaping.
 */
from Call site, Argument arg
where 
    site.getTarget().getName() = "write" or 
    site.getTarget().getName() = "print" or 
    site.getTarget().getName() = "echo" or 
    site.getTarget().getName() = "Response.write" or 
    site.getTarget().getName() = "HttpResponse.write"
    and arg.getValue().getSource() = "request" or 
    arg.getValue().getSource() = "input" or 
    arg.getValue().getSource() = "user"
select site, "Potential reflected XSS: User input directly written to response without sanitization"