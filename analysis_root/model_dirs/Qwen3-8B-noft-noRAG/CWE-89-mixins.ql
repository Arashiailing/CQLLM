import python

/**
 * @name CWE-89: SQL Injection via direct query construction
 */
from StringInterpolation si, Expression expr
where si.getExpression() = expr
  and exists(toString(expr).matches(".*\b(SELECT|UPDATE|DELETE|INSERT)\b.*"))
  and exists(toString(expr).contains("$"))
select expr, "Potential SQL injection via string interpolation"