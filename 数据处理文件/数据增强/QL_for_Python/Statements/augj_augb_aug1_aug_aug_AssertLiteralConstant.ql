/**
 * @name Assert statement tests the truth value of a literal constant
 * @description Identifies assertions that evaluate fixed literal values,
 *              which could lead to unexpected behavior with compiler optimizations.
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

// Identify assert statements checking literal constants outside test environments
from Assert assertion, string literalText
where
  // Exclude assertions within test execution contexts
  not assertion.getScope().getScope*() instanceof TestScope and
  // Extract literal value from the assertion's test expression
  exists(Expr assertionTest | assertionTest = assertion.getTest() |
    // Handle different literal types and convert to string representation
    (literalText = assertionTest.(IntegerLiteral).getN() and
     // Integer literals without quotes
     literalText = assertionTest.(IntegerLiteral).getN())
    or
    // String literals with surrounding quotes
    (literalText = "\"" + assertionTest.(StringLiteral).getS() + "\"")
    or
    // Boolean/None constants converted to string
    (literalText = assertionTest.(NameConstant).toString())
  ) and
  // Exclude assertions at the end of conditional elif branches
  not exists(If conditionalStmt | 
    conditionalStmt.getElif().getAnOrelse() = assertion
  )
select assertion, "Assert of literal constant " + literalText + "."