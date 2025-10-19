import python

/**
 * @name PathTraversal
 * @description Detects potential path traversal vulnerabilities by identifying suspicious patterns in file paths.
 */
from StringLiteral s, Call c
where 
  (s.value contains "../" or s.value contains "./.." or s.value contains "%2e%2e/" or s.value contains "%2e%2e") 
  and c.getMethodName() = "open" 
  and c.getArgument(0) = s
  and not c.getArgument(0).getValue().endsWith("/") // Avoid matching when path ends with slash
select c, "Potential path traversal vulnerability detected through dangerous path pattern."