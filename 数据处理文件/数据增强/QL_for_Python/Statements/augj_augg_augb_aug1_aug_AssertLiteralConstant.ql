/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Detects assert statements that test literal constant values,
 *              which may behave differently when compiler optimizations are enabled.
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
  // Exclude assertions within test scopes to reduce false positives
  not assertStmt.getScope().getScope*() instanceof TestScope and
  
  // Extract the test expression from the assert statement
  exists(Expr testExpr | 
    testExpr = assertStmt.getTest() and
    // Capture literal constant values as string representations
    (
      // Case 1: Integer literals (converted to string)
      literalValue = testExpr.(IntegerLiteral).getN().toString()
      or
      // Case 2: String literals (with escaped quotes)
      literalValue = "\"" + testExpr.(StringLiteral).getS() + "\""
      or
      // Case 3: Name constants (None, True, False)
      literalValue = testExpr.(NameConstant).toString()
    )
  ) and
  // Filter out assertions that appear at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertStmt
  )
select assertStmt, "Assert of literal constant " + literalValue + "."