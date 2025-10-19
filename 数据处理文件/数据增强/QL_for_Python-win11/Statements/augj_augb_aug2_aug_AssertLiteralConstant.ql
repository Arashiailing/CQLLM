/**
 * @name Literal Constant in Assertion Check
 * @description Identifies assertions that compare against literal constants (numbers, strings,
 *              or booleans). Such assertions may behave differently under compiler optimizations,
 *              potentially leading to unexpected program behavior.
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

from Assert assertStmt, string constantValue
where
  // Extract the test expression from the assertion statement
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and
    (
      // Handle integer literals - convert to string representation
      constantValue = testExpr.(IntegerLiteral).getN().toString()
      or
      // Handle string literals - preserve quotes in the output
      constantValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      // Handle name constants (None, True, False) - use their string representation
      constantValue = testExpr.(NameConstant).toString()
    )
  )
  and
  // Exclude assertions that are within test scopes
  not assertStmt.getScope().getScope*() instanceof TestScope
  and
  // Exclude assertions that appear at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + constantValue + "."