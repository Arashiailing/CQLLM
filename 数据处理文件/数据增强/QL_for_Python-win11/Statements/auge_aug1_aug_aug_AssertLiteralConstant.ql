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

// Identify assert statements that check literal constant values, which may be problematic
// due to compiler optimizations potentially removing them
from Assert assertStmt, string constantValue
where
  // Filter out assertions within test code execution environments
  not assertStmt.getScope().getScope*() instanceof TestScope
  
  // Extract the constant value from various literal types in the assertion expression
  and exists(Expr assertionExpr | 
    assertionExpr = assertStmt.getTest() and (
      // Process integer literals directly
      constantValue = assertionExpr.(IntegerLiteral).getN()
      or
      // Format string literals with quotation marks for clear representation
      constantValue = "\"" + assertionExpr.(StringLiteral).getS() + "\""
      or
      // Handle boolean and None constants by converting to string representation
      constantValue = assertionExpr.(NameConstant).toString()
    )
  )
  
  // Eliminate assertions at the end of conditional elif branches
  and not exists(If ifCondition | ifCondition.getElif().getAnOrelse() = assertStmt)
select assertStmt, "Assert of literal constant " + constantValue + "."