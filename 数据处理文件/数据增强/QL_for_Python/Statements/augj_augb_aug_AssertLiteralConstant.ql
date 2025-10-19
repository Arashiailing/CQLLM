/**
 * @name Assertion on Literal Constant
 * @description Identifies assert statements using literal constants (integers, strings, 
 *              or booleans) as test conditions. Such assertions may be unpredictably 
 *              optimized by compilers, potentially causing inconsistent behavior.
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
  // Exclude assertions within test code scopes
  not assertStmt.getScope().getScope*() instanceof TestScope and
  // Check for literal constants in the assertion's test expression
  exists(Expr conditionExpr | 
    conditionExpr = assertStmt.getTest() and (
      // Case 1: Integer literals
      literalValue = conditionExpr.(IntegerLiteral).getN() or
      // Case 2: String literals with escaped quotes
      literalValue = "\"" + conditionExpr.(StringLiteral).getS() + "\"" or
      // Case 3: Boolean/None constants
      literalValue = conditionExpr.(NameConstant).toString()
    )
  ) and
  // Exclude assertions at the end of elif branches
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."