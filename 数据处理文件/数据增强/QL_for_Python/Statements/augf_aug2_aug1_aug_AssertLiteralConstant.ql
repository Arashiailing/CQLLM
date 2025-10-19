/**
 * @name Assertion of a literal constant value
 * @description Flags assert statements that check literal constants, which may behave 
 *              unpredictably under compiler optimizations due to their static nature.
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

from Assert assertionStmt, string literalConstValue
where
  // Exclude assertions in test environments to reduce noise
  not assertionStmt.getScope().getScope*() instanceof TestScope and
  // Skip assertions at the end of elif chains (likely control flow)
  not exists(If conditional | 
    conditional.getElif().getAnOrelse() = assertionStmt
  ) and
  // Identify literal constants in assertion test expressions
  exists(Expr testExpr | 
    testExpr = assertionStmt.getTest() and (
      // Handle integer literals
      literalConstValue = testExpr.(IntegerLiteral).getN() or
      // Handle string literals with escaped quotes
      literalConstValue = "\"" + testExpr.(StringLiteral).getS() + "\"" or
      // Handle name constants (None, True, False)
      literalConstValue = testExpr.(NameConstant).toString()
    )
  )
select assertionStmt, "Assert of literal constant " + literalConstValue + "."