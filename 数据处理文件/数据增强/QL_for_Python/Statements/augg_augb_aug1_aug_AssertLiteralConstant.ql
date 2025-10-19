/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that test literal constant values,
 *              which may behave differently when compiler optimizations are enabled.
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
  // Exclude assertions within test scopes to reduce false positives
  not assertionStmt.getScope().getScope*() instanceof TestScope and
  // Check if the assert statement tests a literal constant
  exists(Expr testExpression | 
    testExpression = assertionStmt.getTest() and (
      // Handle integer literals
      constantValue = testExpression.(IntegerLiteral).getN() or
      // Handle string literals with escaped quotes
      constantValue = "\"" + testExpression.(StringLiteral).getS() + "\"" or
      // Handle name constants (None, True, False)
      constantValue = testExpression.(NameConstant).toString()
    )
  ) and
  // Filter out assertions that appear at the end of elif chains
  not exists(If ifStatement | 
    ifStatement.getElif().getAnOrelse() = assertionStmt
  )
select assertionStmt, "Assert of literal constant " + constantValue + "."