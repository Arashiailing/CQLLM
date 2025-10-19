/**
 * @name Assert statement tests the truth value of a literal constant
 * @description An assert statement testing a literal constant value may exhibit
 *              different behavior when optimizations are enabled.
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

from Assert stmt, string literalValue
where
  // Filter out assertions within test scopes to reduce false positives
  not stmt.getScope().getScope*() instanceof TestScope and
  // Identify literal constant expressions in the assertion test
  exists(Expr testExpr | 
    testExpr = stmt.getTest() and (
      // Process integer literal constants
      literalValue = testExpr.(IntegerLiteral).getN() or
      // Process string literal constants with escaped quotes
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Process name constants (None, True, False)
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = stmt
  )
select stmt, "Assert of literal constant " + literalValue + "."