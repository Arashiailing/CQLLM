/**
 * @name Assertion tests a literal constant
 * @description Detects assertions that test literal constants (numbers, strings, booleans).
 *              Such assertions may behave unexpectedly with compiler optimizations enabled.
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
  // Skip assertions within test code
  not assertStmt.getScope().getScope*() instanceof TestScope
  and
  // Extract literal constant from assertion test expression
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and
    (
      // Integer literal (preserve numeric representation)
      literalValue = testExpr.(IntegerLiteral).getN().toString()
      or
      // String literal (preserve quotes in output)
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      // Name constant (None, True, False)
      literalValue = testExpr.(NameConstant).toString()
    )
  )
  and
  // Exclude assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."