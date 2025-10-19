/**
 * @name Assertion Checks Using Literal Constants
 * @description Identifies assertions comparing against literal constants (numbers, strings, 
 *              or booleans). Such assertions may behave unpredictably under compiler optimizations,
 *              potentially causing unexpected program behavior.
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

from Assert assertion, string literalValue
where
  // Extract literal constant from assertion's test expression
  exists(Expr assertionTestExpr | 
    assertionTestExpr = assertion.getTest() and
    (
      // Convert integer literals to string representation
      literalValue = assertionTestExpr.(IntegerLiteral).getN().toString()
      or
      // Preserve quotes for string literals in output
      literalValue = "\"" + assertionTestExpr.(StringLiteral).getS() + "\""
      or
      // Handle name constants (None, True, False)
      literalValue = assertionTestExpr.(NameConstant).toString()
    )
  )
  and
  // Exclude assertions within test scopes
  not assertion.getScope().getScope*() instanceof TestScope
  and
  // Exclude assertions at the end of elif chains
  not exists(If ifStmt | 
    ifStmt.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + literalValue + "."