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

from Assert assertStmt, string literalValue
where
  // Filter out assertions within test scopes to prevent false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Identify literal constant expressions used in assertion tests
  exists(Expr assertExpr | 
    assertExpr = assertStmt.getTest() and (
      // Process integer literal constants
      literalValue = assertExpr.(IntegerLiteral).getN() or
      // Process string literal constants with escaped quotes
      literalValue = "\"" + assertExpr.(StringLiteral).getS() + "\"" or
      // Process name constants (None, True, False)
      literalValue = assertExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions that appear at the end of elif chains
  not exists(If conditionalStmt | 
    conditionalStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."