/**
 * @name Assertion tests a literal constant
 * @description Finds assertions that verify literal values (integers, strings, booleans).
 *              These assertions might exhibit inconsistent behavior when compiler
 *              optimizations are applied, leading to potential runtime issues.
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
  // Skip assertions located within test code
  not assertStmt.getScope().getScope*() instanceof TestScope
  and
  // Extract the literal constant value from the assertion's test expression
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and
    (
      // For integer literals, convert to string without quotes
      literalValue = testExpr.(IntegerLiteral).getN().toString()
      or
      // For string literals, preserve quotes in the output
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      // For name constants (None, True, False), use their string representation
      literalValue = testExpr.(NameConstant).toString()
    )
  )
  and
  // Filter out assertions that serve as the final branch in an if-elif chain
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."