/**
 * @name CWE-264: Improper Authorization
 * @description Detects instances where improper authorization is being enforced.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id py/improper-authorization
 */

import python

from Function func, Expr condition
where
  func.hasName("checkAuthorization") and
  condition = func.getBody().findDescendant(IfStmt) and
  condition.getCondition() = func.getParameter("userRole")
select func, "Improper authorization check found."