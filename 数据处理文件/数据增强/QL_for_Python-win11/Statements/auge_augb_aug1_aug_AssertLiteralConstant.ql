/**
 * @name Assertion checks against literal constants
 * @description Assertions that evaluate literal constants may behave differently
 *              under compiler optimization settings.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/assert-literal-constant
 */

import python
import semmle.python.filters.Tests

from Assert assertionStmt, string constantValue
where
  // Exclude assertions within test frameworks to reduce noise
  not assertionStmt.getScope().getScope*() instanceof TestScope and
  // Check if the assertion tests a literal constant value
  exists(Expr assertionExpr | 
    assertionExpr = assertionStmt.getTest() and (
      // Handle numeric literals (integers)
      constantValue = assertionExpr.(IntegerLiteral).getN() or
      // Handle string literals with proper escaping
      constantValue = "\"" + assertionExpr.(StringLiteral).getS() + "\"" or
      // Handle boolean and None constants
      constantValue = assertionExpr.(NameConstant).toString()
    )
  ) and
  // Filter out assertions that serve as final elif conditions
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertionStmt
  )
select assertionStmt, "Assert of literal constant " + constantValue + "."