/**
 * @name Assertion of a literal constant value
 * @description Detects assert statements that check literal constants (integers, strings, booleans, None).
 *              Such assertions may behave unpredictably under compiler optimizations.
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

from Assert assertionStatement, string constantLiteralValue
where
  // Exclude test code to minimize false positives
  not assertionStatement.getScope().getScope*() instanceof TestScope and
  // Identify assertions checking literal constants
  exists(Expr assertionTestExpr | 
    assertionTestExpr = assertionStatement.getTest() and (
      // Handle integer literals
      constantLiteralValue = assertionTestExpr.(IntegerLiteral).getN() or
      // Handle string literals with escaped quotes
      constantLiteralValue = "\"" + assertionTestExpr.(StringLiteral).getS() + "\"" or
      // Handle name constants (None, True, False)
      constantLiteralValue = assertionTestExpr.(NameConstant).toString()
    )
  ) and
  // Filter out assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertionStatement
  )
select assertionStatement, "Assert of literal constant " + constantLiteralValue + "."