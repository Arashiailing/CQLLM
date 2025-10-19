/**
 * @name Assertion tests a literal constant
 * @description An assertion that tests a literal constant (like a number, string, or boolean)
 *              may behave differently when compiler optimizations are enabled, potentially
 *              leading to unexpected behavior.
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
  // Exclude assertions within test scopes
  not assertionStmt.getScope().getScope*() instanceof TestScope
  and
  // Identify literal constant expressions in the assertion test
  exists(Expr testExpression | 
    testExpression = assertionStmt.getTest() and
    (
      // Handle integer literals (converted to string without quotes)
      constantValue = testExpression.(IntegerLiteral).getN().toString()
      or
      // Handle string literals (preserving quotes in output)
      constantValue = "\"" + testExpression.(StringLiteral).getS() + "\""
      or
      // Handle name constants (None, True, False)
      constantValue = testExpression.(NameConstant).toString()
    )
  )
  and
  // Exclude assertions at the end of elif chains
  not exists(If ifStatement | 
    ifStatement.getElif().getAnOrelse() = assertionStmt
  )
select assertionStmt, "Assert of literal constant " + constantValue + "."