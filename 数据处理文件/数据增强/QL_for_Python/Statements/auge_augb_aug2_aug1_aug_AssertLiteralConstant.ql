/**
 * @name Assertion of a literal constant value
 * @description Identifies assert statements that verify literal constants (integers, strings, booleans, None).
 *              These assertions might exhibit inconsistent behavior when compiler optimizations are applied.
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
  // Exclude test files to reduce false positive results
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Extract the expression being tested in the assertion
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and (
      // Process integer literal values
      literalValue = testExpr.(IntegerLiteral).getN() or
      // Process string literals with properly escaped quotes
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Process name constants including None, True, and False
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions located at the end of elif statement chains
  not exists(If conditionalStmt | 
    conditionalStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."