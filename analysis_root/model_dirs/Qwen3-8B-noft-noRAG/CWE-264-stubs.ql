import python

/**
 * Query to detect potential CWE-264 (Insecure Direct Object References)
 * by identifying direct usage of unvalidated parameters from HTTP requests.
 */
from Call c
where c.getCallee().getKind() = "Function" and 
      c.getCallee().getName() = "get" and 
      c.getParent().isMemberAccess() and 
      c.getParent().getBase().getName() = "args" and 
      c.getParent().getBase().getBase().getName() = "request"
select c, "Potential CWE-264: Insecure Direct Object Reference - Unvalidated parameter from request arguments."