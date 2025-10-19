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
  // Exclude test case assertions by checking scope hierarchy
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Identify literal constant expressions in the assertion test
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and (
      // Handle integer literals
      literalValue = testExpr.(IntegerLiteral).getN() or
      // Handle string literals with quotes
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Handle name constants (None, True, False)
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."