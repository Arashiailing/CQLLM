import python

/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description Detects potential path traversal vulnerabilities by analyzing file operations that may allow malicious path manipulation.
 */
from Call c, Argument a
where c.getTarget().getName() = "open"
   and a.getType().isStringType()
   and exists (DataFlow::getSourceFrom(a, null))
select a, "Potential path traversal vulnerability through open function with unvalidated input"