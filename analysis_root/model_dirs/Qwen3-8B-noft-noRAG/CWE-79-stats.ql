import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/stats
 */

from MethodCall, Assignment, StringLiteral
where 
  // Find assignments that take user input (e.g., from request parameters)
  Assignment.lhs = "response" and 
  Assignment.rhs = MethodCall and 
  MethodCall.method.name = "write" and 
  MethodCall.arguments[0].value is StringLiteral and 
  // Check if the string literal contains unescaped user input patterns
  (StringLiteral.value like "%${%") or 
  (StringLiteral.value like "%}%") or 
  (StringLiteral.value like "%<script>%") or 
  (StringLiteral.value like "%</script>%") or 
  (StringLiteral.value like "%<img src=.%") or 
  (StringLiteral.value like "%onerror=%")
select MethodCall, "Potential reflected XSS vulnerability detected: User input is directly written to HTML without proper escaping."